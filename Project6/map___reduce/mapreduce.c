#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <string.h>
#include "mapreduce.h"

#define numThreads 100
int threadCounter;
int numberOfFiles;
char** fileNames;
Mapper mapFunction;
Reducer reduceFunction;
Partitioner partitionerFunction;
int noMapperThreads;
int noReducerThreads;
int noPartitions;
pthread_mutex_t fLock = PTHREAD_MUTEX_INITIALIZER;

typedef struct _VNode {
  char* value;
  struct _VNode* next;
} VNode;

typedef struct KVNode {
  char* key;
  VNode *valueHead;
  VNode *curNode;
} KVNode;

typedef struct Partition {
  int size;
  pthread_mutex_t lock;
  KVNode *kvNodes[30000000];
} Partition;

Partition** partitions;

unsigned long MR_DefaultHashPartition(char *key, int num_partitions) {
  unsigned long hash = 5381;
  int c;
  while ((c = *key++) != '\0')
      hash = hash * 33 + c;
  return hash % num_partitions;
}

void cleanup() {
  for (int i = 0; i < noPartitions; i++) {
    Partition *requiredPartition = partitions[i];
    for(int j = 0; j < requiredPartition->size; j++) {
      KVNode* currKVNode = requiredPartition->kvNodes[j];
      free(currKVNode->key);
      free(currKVNode->curNode);
      while(currKVNode->valueHead != NULL) {
        free(currKVNode->valueHead->value);
	currKVNode->valueHead = currKVNode->valueHead->next;
      }
      free(currKVNode->valueHead);
      free(currKVNode);
    }
    free(requiredPartition);
  }
}


KVNode* bSearch(Partition* p, char* key) {
  int last = p->size;
  int first = 0;
  while (first <= last) {
    int mid = (first+last)/2;
    KVNode* cur = p->kvNodes[mid];
    if (strcmp(key, cur->key) == 0) {
         return cur;
    } else if (strcmp(key, cur->key) >  0) {
       first = mid+1;
    } else if (strcmp(key, cur->key) < 0) {
       last = mid - 1;
    }
  }
  return NULL;
}

void initialize(int argc, char* argv[], Mapper map, int num_mappers,
  Reducer reduce, int num_reducers, Partitioner partition,
  int num_partitions) {
  numberOfFiles = argc - 1;
  fileNames = argv+1;
  mapFunction = map;
  reduceFunction = reduce;
  noMapperThreads = num_mappers;
  noReducerThreads = num_reducers;
  partitionerFunction = partition;
  noPartitions = num_partitions;
}

int powerOfTwo(int x) {
  return (x > 1) ? 1 + powerOfTwo(x/2) : 0;
}
int bitExtracted(int number, int k, int p) {
  return (((1 << k) - 1) & (number >> (p - 1)));
}

unsigned long MR_SortedPartition(char *key, int num_partitions) {
  int shiftBy = powerOfTwo(num_partitions);
  unsigned long res = strtoul(key, NULL, 0);
  unsigned long t = bitExtracted(res, shiftBy, 0);
  return t;
}

void initializePartitions() {
  partitions = malloc(sizeof(Partition) * noPartitions);
  for (int i = 0; i < noPartitions; i++) {
    partitions[i] = malloc(sizeof(Partition));
    pthread_mutex_init(&(partitions[i]->lock), NULL);
    partitions[i]->size = -1;
  }
}

char *get_next(char *key, int pNum) {
  Partition *p = partitions[pNum];
  KVNode *kNode = bSearch(p, key);
  if (kNode == NULL) {
     return NULL;
  } else {
     if (kNode->curNode == NULL) {
       return NULL;
     }
     char *c = kNode->curNode->value;
     kNode->curNode = kNode->curNode->next;
     return c;
  }
}

void* reducer(void *arg) {
  pthread_mutex_lock(&fLock);
  while (threadCounter <= noPartitions) {
    if (threadCounter == noPartitions) {
       pthread_mutex_unlock(&fLock);
       return NULL;
    }
    int local = threadCounter;
    Partition *p = partitions[threadCounter++];
    pthread_mutex_unlock(&fLock);
    int i = 0;
    while (p->kvNodes[i] != NULL) {
      reduceFunction(p->kvNodes[i]->key, get_next, local);
      i++;
    }
  }
  return NULL;
}

void* map_files(void* arg) {
  char* name;
  pthread_mutex_lock(&fLock);
  while (threadCounter <= numberOfFiles) {
    if (threadCounter == numberOfFiles) {
      pthread_mutex_unlock(&fLock);
      return NULL;
    }
    name = fileNames[threadCounter++];
    pthread_mutex_unlock(&fLock);
    mapFunction(name);
    }
    return NULL;
}


void threadHandler(int threadType, int numOfThread) {
  if (threadType == 0) {
    int temp = noMapperThreads < numberOfFiles ?
          noMapperThreads : numberOfFiles;
    pthread_t mapper_thread[1000];
    for (int i=0; i < temp; i++) {
      if (pthread_create(&mapper_thread[i], NULL, map_files, NULL) != 0) {
          printf("threadHandler: Mapper thread create fails \n");
          exit(1);
      }
    }
    for (int i = 0; i < temp; i++) {
      pthread_join(mapper_thread[i], NULL);
    }
  } else {
    int *index;
    int temp = noReducerThreads < noPartitions ?
         noReducerThreads : noPartitions;
    pthread_t reducer_thread[1000];
    for (int i=0; i< temp; i++) {
      index = (int*)malloc(sizeof(int));
      *index = i;
      if (pthread_create(&reducer_thread[i], NULL, reducer, NULL) != 0) {
          printf("threadHanlder: Reducer thread create fail \n");
          exit(1);
      }
    }
    for (int i = 0; i < temp; i++) {
      pthread_join(reducer_thread[i], NULL);
    }
  }
}

int comparator(const void* kv1, const void* kv2) {
    KVNode* kvn1 = *((KVNode**) kv1);
    KVNode* kvn2 = *((KVNode**) kv2);
    if (kvn1 == NULL)
        return 1;
    else if (kvn2 == NULL)
        return -1;
    else
        return strcmp(kvn1->key, kvn2->key);
}


void sort(Partition** partitions) {
  for (int i = 0; i < noPartitions; i++) {
    if (partitions[i]->size >= 0) {
      qsort(partitions[i]->kvNodes, partitions[i]->size + 1,
            sizeof(KVNode*), comparator);
    }
  }
}

void MR_Emit(char *key, char *value) {
  int partitionIndex = partitionerFunction(key, noPartitions);
  Partition *requiredPartition = partitions[partitionIndex];
  pthread_mutex_lock(&(requiredPartition->lock));
  VNode *newValueNode = (VNode*)malloc(sizeof(VNode));
  newValueNode->value = malloc(sizeof(char)*20);
  //newValueNode->value = strdup(value);
  strcpy(newValueNode->value, value);
  int found = 0;
  KVNode* tempKVNode;
  for (int i = 0; i <= requiredPartition->size; i++) {
    tempKVNode = requiredPartition->kvNodes[i];
    if (strcmp(tempKVNode->key, key) == 0) {
      found = 1;
        break;
    }
  }
  if (found == 1) {
    newValueNode->next = tempKVNode->valueHead;
    tempKVNode->valueHead = newValueNode;
    tempKVNode->curNode = tempKVNode->valueHead;
    pthread_mutex_unlock(&(requiredPartition->lock));
    return;
  } else {
    KVNode* newKVNode = (KVNode*)malloc(sizeof(KVNode));
    newKVNode->key = malloc(sizeof(char)*20);
    strcpy(newKVNode->key, key);
    newValueNode->next = NULL;
    newKVNode->valueHead = newValueNode;
    newKVNode->curNode = newKVNode->valueHead;
    requiredPartition->size++;
    requiredPartition->kvNodes[requiredPartition->size] = newKVNode;
    pthread_mutex_unlock(&(requiredPartition->lock));
    return;
  }
}

void MR_Run(int argc, char *argv[], Mapper map, int num_mappers,
Reducer reduce, int num_reducers, Partitioner partition,
int num_partitions) {
  initialize(argc, argv, map, num_mappers, reduce,
      num_reducers, partition, num_partitions);
  initializePartitions();
  threadCounter = 0;
  threadHandler(0, noMapperThreads);
  threadCounter = 0;
  sort(partitions);
  threadHandler(1, noReducerThreads);
  cleanup();
}
