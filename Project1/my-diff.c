// Copyright 2019 Shaurya

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

#define MAX 100

int main(int argc, char** argv) {
    if (argc != 3) {
        printf("my-diff: invalid number of arguments\n");
        exit(1);
    }
    char file1[MAX];
    char file2[MAX];
    strcpy(file1, argv[1]);
    strcpy(file2, argv[2]);
    char *line1 = NULL;
    char *line2 = NULL;
    size_t len1 = 0;
    size_t len2 = 0;
    size_t nread1, nread2;
    FILE* filePtr1;
    filePtr1 = fopen(file1, "r");
    FILE* filePtr2;
    filePtr2 = fopen(file2, "r");
    if (filePtr1 == NULL || filePtr2 == NULL) {
                printf("my-diff: cannot open file\n");
                exit(1);
    }
    int lineNumber = 1;
    int lastPrintedLineNumber = -1;
    while ( ((nread1 = getline(&line1, &len1, filePtr1)) != -1)
            && ((nread2 = getline(&line2, &len2, filePtr2)) != -1) ) {
            if (line1[nread1-1] == '\n') {
                line1[nread1-1] = '\0';
                nread1--;
            }
            if (line2[nread2-1] == '\n') {
                line2[nread2-1] = '\0';
                nread2--;
            }
            if (strcmp(line1, line2) != 0) {
                if ((lineNumber - lastPrintedLineNumber) > 1) {
                        printf("%d\n", lineNumber);
            }
            printf("< %s\n", line1);
            printf("> %s\n", line2);
            lastPrintedLineNumber = lineNumber;
        }
        lineNumber++;
    }
    if (nread1 == -1) {
        while ((nread2 = getline(&line2, &len2, filePtr2)) != -1) {
            if ((lineNumber - lastPrintedLineNumber) > 1) {
                printf("%d\n", lineNumber);
            }
            if (line2[nread2-1] == '\n') {
                line2[nread2-1] = '\0';
                nread2--;
            }
            printf("> %s\n", line2);
            lastPrintedLineNumber = lineNumber;
            lineNumber++;
        }
    } else if (nread2 == -1) {
        if ((lineNumber - lastPrintedLineNumber) > 1) {
                printf("%d\n", lineNumber);
            }
            if (line1[nread1-1] == '\n') {
                line1[nread1-1] = '\0';
                nread1--;
            }
            printf("< %s\n", line1);
            lastPrintedLineNumber = lineNumber;
            lineNumber++;
        while ((nread1 = getline(&line1, &len1, filePtr1)) != -1) {
            if ((lineNumber - lastPrintedLineNumber) > 1) {
                printf("%d\n", lineNumber);
            }
            if (line1[nread1-1] == '\n') {
                line1[nread1-1] = '\0';
                nread1--;
            }
            printf("< %s\n", line1);
            lastPrintedLineNumber = lineNumber;
            lineNumber++;
        }
    }
    fclose(filePtr1);
    fclose(filePtr2);
    return 0;
}
