// Copyright: Shaurya For CS537 - Project 3
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <limits.h>
#include <errno.h>
#include <ctype.h>

int isBatch = 0;
int isRedir = 0;
int overallBackground = 0;
char errorMessage[30] = "An error has occurred\n";
char *jobNotFound = ": Command not found\n";
char *prompt = "mysh> ";
char *newLine = "\n";
char *separator = " : ";
char *space = " ";
char *fileOpenErrorMessage = "Error: Cannot open file ";
char *argumentWrongMessage = "Usage: mysh [batchFile]\n";
char *noJobsMessage = "No Jobs Running\n";
char *outputs[512];
char *parts[512];
char *cmdDuplicateWithNullCharachter;
char *line;
FILE *input;

struct record {
      int id;
      char *command;
      char *arguments[25];
      int numberOfTokens;
      pid_t pid;
      int isForeground;
} jobRecords[100];
int jobCounter = -1;

void printErrorMessage() {
    write(2, errorMessage, strlen(errorMessage));
}
void printMyshPrompt() {
    if (!isBatch) {
        write(1, prompt, strlen(prompt));
    }
}
void printWrongArgumentMessage() {
    write(2, argumentWrongMessage, strlen(argumentWrongMessage));
}
void printFileOpenErrorMessage(char *fileName) {
    write(2, fileOpenErrorMessage, strlen(fileOpenErrorMessage));
    write(2, fileName, strlen(fileName));
    write(2, newLine, strlen(newLine));
}
void printInvalidJobID(char jid[]) {
     write(2, "Invalid JID ", strlen("Invalid JID "));
     write(2, jid, strlen(jid));
     write(2, newLine, strlen(newLine));
}
void printJobNotFound(char jobName[]) {
     write(2, jobName, strlen(jobName));
     write(2, jobNotFound, strlen(jobNotFound));
}
void printJobRecords() {
     for (int z=0; z <= jobCounter; z++) {
         int status;
         pid_t return_pid = waitpid(jobRecords[z].pid, &status, WNOHANG);
         if (return_pid == 0) {
            int jobId = jobRecords[z].id;
            char number[20];
            snprintf(number, sizeof(number), "%d", jobId);
            write(1, number, strlen(number));
            write(1, separator, strlen(separator));
            write(1, jobRecords[z].command,
                   strlen(jobRecords[z].command));
            for (int k=0; k < jobRecords[z].numberOfTokens - 1; k++) {
                 if (strchr(jobRecords[z].arguments[k], '&') != NULL) {
                     continue;
                 } else {
                     write(1, space, strlen(space));
                     write(1, jobRecords[z].arguments[k],
                                          strlen(jobRecords[z].arguments[k]));
                 }
            }
            write(1, newLine, strlen(newLine));
         }
    }
}

int splitLine(char *line, char *words[]) {
    int wordsSize = 0;
    words[0] = strtok(line, " ");
    while (words[wordsSize] != NULL) {
         words[++wordsSize] = strtok(NULL, " ");
    }
    return wordsSize;
}
int isNumber(char *part) {
    for (int i = 0; part[i] != '\0'; i++) {
        if (!isdigit(part[i])) {
             return 0;
        }
    }
    return 1;
}
int isEmpty(char *line) {
    int returnValue = 1;
    for (int i = 0; i < strlen(line); i++) {
        char c = line[i];
        if (c != ' ' && c != '\n') {
             returnValue = 0;
             break;
        }
    }
    return returnValue;
}

int isBackgroundProcess(char *parts[], int partsSize) {
    int ampersandPosition = 0;
    char *result;
    result = strchr(parts[partsSize-1], '&');
    if (result != NULL) {
         ampersandPosition = 1;
    }
    if (ampersandPosition == 1) {
    parts[partsSize-1] = 0;
    return 1;
    }
    return 0;
}

void addToJobsRecord(char *parts[], int partsSize) {
    jobCounter++;
    jobRecords[jobCounter].id = jobCounter;
    jobRecords[jobCounter].command = parts[0];
    int position = 0;
    jobRecords[jobCounter].numberOfTokens = partsSize;
    for (int k=1; k <= partsSize; k++) {
         jobRecords[jobCounter].arguments[position] = parts[k];
         position++;
    }
}

void exitFunctionality(char *parts[], int partsSize) {
     if ((partsSize == 1) ||
            (partsSize == 2 && strchr(parts[1], '&') != NULL)) {
         fclose(input);
         free(cmdDuplicateWithNullCharachter);
         exit(0);
    }
}

void waitFunctionality(int queriedJobID) {
     char number[20];
     snprintf(number, sizeof(number), "%d", queriedJobID);
     if (queriedJobID > jobCounter || queriedJobID < 0) {
         printInvalidJobID(number);
     } else if (jobRecords[queriedJobID].isForeground) {
         printInvalidJobID(number);
     } else {
         pid_t requiredProcessID = jobRecords[queriedJobID].pid;
         int status;
         pid_t returnPid = waitpid(requiredProcessID, &status, WUNTRACED);
         if (returnPid == 0) {
              printf("Just to check returnPid\n");
         }
         char *jid = "JID ";
         write(1, jid, strlen(jid));
         write(1, number, strlen(number));
         char *finish = " terminated\n";
         write(1, finish, strlen(finish));
     }
}

void execute(char *cmd) {
    cmdDuplicateWithNullCharachter = strdup(cmd);
    line = cmdDuplicateWithNullCharachter;
    char *forwardAmpersand = strchr(line, '>');
    char *backwardAmpersand = strrchr(line, '>');
    char *beforeAmpersand, *afterAmpersand;
    int partsSize;
    if (forwardAmpersand != NULL && forwardAmpersand == backwardAmpersand) {
         beforeAmpersand = strtok(line, ">");
         afterAmpersand = strtok(NULL, "\n");
         int postRedirectionTokens = splitLine(afterAmpersand, outputs);
         if (postRedirectionTokens < 1 || postRedirectionTokens > 2 ||
                (postRedirectionTokens == 2 &&
                   (strchr(outputs[postRedirectionTokens-1], '&') == NULL))) {
              printErrorMessage();
              return;
         }
         if (strchr(outputs[postRedirectionTokens-1], '&') != NULL) {
              overallBackground = 1;
         }
         partsSize = splitLine(beforeAmpersand, parts);
         close(1);
         if (partsSize == 0 ||
                 open(outputs[0], O_WRONLY | O_TRUNC | O_CREAT, S_IRWXU) < 0) {
             printErrorMessage();
             return;
         }
         isRedir = 1;
    } else if (forwardAmpersand && forwardAmpersand != backwardAmpersand) {
            printErrorMessage();
            return;
    } else {
         partsSize = splitLine(strtok(line, "\n"), parts);
         if (partsSize == 0) {
             printErrorMessage();
             return;
         }
    }
    if (strcmp(parts[0], "exit") == 0) {
         exitFunctionality(parts, partsSize);
    }
    if (strcmp(parts[0], "jobs") == 0) {
         if (partsSize == 1 ||
             (partsSize == 2 && strchr(parts[1], '&') != NULL)) {
               if (jobCounter == -1) {
                     write(2, noJobsMessage, strlen(noJobsMessage));
               } else {
                     printJobRecords();
               }
          }
          return;
    }
    if (strcmp(parts[0], "wait") == 0) {
        if ((partsSize ==2 && isNumber(parts[1])) || (partsSize == 3 &&
                     isNumber(parts[1]) && strchr(parts[2], '&') != NULL)) {
         int queriedJobID = atoi(parts[1]);
         waitFunctionality(queriedJobID);
         return;
     }
    }
    addToJobsRecord(parts, partsSize);
    if (isBackgroundProcess(parts, partsSize) || overallBackground) {
         int rc = fork();
         if (rc == 0) {
              execvp(parts[0], parts);
              printJobNotFound(parts[0]);
              exit(1);
         } else if (rc > 0) {
              jobRecords[jobCounter].pid = rc;
              jobRecords[jobCounter].isForeground = 0;
         } else {
              printErrorMessage();
         }
    } else {
         int rc = fork();
         if (rc == 0) {
             execvp(parts[0], parts);
             printJobNotFound(parts[0]);
             exit(1);
         } else if (rc > 0) {
             wait(NULL);
             jobRecords[jobCounter].pid = rc;
             jobRecords[jobCounter].isForeground = 1;
         } else {
             printErrorMessage();
         }
    }
}

int main(int argc, char** argv) {
    char line[1024];
    if (argc == 2) {
        isBatch = 1;
        input = fopen(argv[1], "r");
        if (input == NULL) {
             printFileOpenErrorMessage(argv[1]);
             exit(1);
        }
    } else if (argc == 1) {
           input = stdin;
    } else {
           printWrongArgumentMessage();
           free(cmdDuplicateWithNullCharachter);
           exit(1);
    }
    printMyshPrompt();
    while (fgets(line, 700, input) != NULL) {
        if (line[0] == '\r' || line[0] == '\n') {
            if (isBatch) {
                write(1, line, strlen(line));
            }
            goto skipLoop;
        }
        int empty = isEmpty(line);
        if (empty) {
             if (isBatch) {
                  write(1, line, strlen(line));
             }
             goto skipLoop;
        }
        if (strlen(line) > 512) {
             if (isBatch) {
                  write(1, line, strlen(line));
             }
             printErrorMessage();
             printMyshPrompt();
             goto skipLoop;
        }
        if (isBatch) {
             write(1, line, strlen(line));
        }
        int copy = dup(1);
        char *cmd = line;
        execute(cmd);
        if (isRedir) {
             dup2(copy, 1);
        }
        skipLoop:
        printMyshPrompt();
    }
    free(cmdDuplicateWithNullCharachter);
    fclose(input);
    return 0;
}
