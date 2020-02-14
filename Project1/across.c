// Copyright 2019 Shaurya

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

#define MAX 100

int strpos(char* buffer, char* key) {
        char* posSubStr = strstr(buffer, key);
        if (posSubStr) {
                return posSubStr - buffer;
        } else {
                return -1;
        }
}

int isLowerCase(char* buffer) {
        for (int i = 0; i < strlen(buffer) - 1; i++) {
                if (!islower(buffer[i])) {
                        return 0;
                }
        }
        return 1;
}

int main(int argc, char** argv) {
        char key[MAX];
        char fileName[MAX];
        char positionC[MAX];
        char lengthC[MAX];
        int position, length;
        if (argc < 4 || argc >= 6) {
                printf("across: invalid number of arguments\n");
                exit(1);
        }
        strcpy(key, argv[1]);
        if (argc == 5) {
                strcpy(fileName, argv[4]);
        } else {
                strcpy(fileName, "/usr/share/dict/words");
        }
        strcpy(positionC, argv[2]);
        strcpy(lengthC, argv[3]);
        position = atoi(positionC);
        length = atoi(lengthC);
        FILE* filePtr;
        filePtr = fopen(fileName, "r");
        if (filePtr == NULL) {
                printf("across: cannot open file\n");
                exit(1);
        }
        int lengthSubStr = strlen(key);
        if (position + lengthSubStr >= length + 1) {
                printf("across: invalid position\n");
                exit(1);
        }
        char buffer[MAX];
        while (fgets(buffer, 100, filePtr) != NULL) {
               if (strlen(buffer) == length+1 && isLowerCase(buffer)) {
                        int pos = strpos(buffer, key);
                        if (pos == position) {
                        printf("%s", buffer);
                        }
               }
        }
        fclose(filePtr);
        return 0;
}
