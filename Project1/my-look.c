// Copyright 2019 Shaurya

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define MAX 100

int main(int argc, char** argv) {
        char key[MAX];
        char fileName[MAX];
        if (argc == 1 || argc >= 4) {
                printf("my-look: invalid number of arguments\n");
                exit(1);
        }
        if (argc == 3) {
                strcpy(fileName, argv[2]);
        } else {
                strcpy(fileName, "/usr/share/dict/words");
        }
        strcpy(key, argv[1]);
        FILE* filePtr;
        filePtr = fopen(fileName, "r");
        if (filePtr == NULL) {
                printf("my-look: cannot open file\n");
                exit(1);
        }
        char buffer[MAX];
        while (fgets(buffer, 100, filePtr) != NULL) {
               if (!strncasecmp(key, buffer, strlen(key))) {
                        printf("%s", buffer);
               }
        }
        fclose(filePtr);
        return 0;
}
