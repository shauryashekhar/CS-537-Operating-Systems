haurya Shekhar
UW NetID: sshekhar4

CS 537
Project 1

my-look.c
- Accepts arguments: substring fileName
- If fileName is not provided defaults to '/usr/share/dict/words'.
- Error handling for wrong number of parameters & in case unable to open mentioned file
- Opens file using fopen() and uses fgets() to read line by line. Since, it is known that size of text in a line will be limited to one word, the size has been defined using a pre-processor directive to 100.
- Uses strncasecmp to perform comparison between text read from file and text provided.

across.c
- Accepts arguments: substring positionAtWhichSubstringShouldOccur lengthOfPrintedWords fileName
- If fileName is not provided defaults to '/usr/share/dict/words'.
- Error handling for wrong number of parameters & in case unable to open mentioned file and also in case (lengthOfPrintedWords < positionAtWhichSubstringShouldOccur + lengthOfSubstringToBeSearchedFor)
- Opens file using fopen() and uses fgets() to read line by line. Since, it is known that size of text in a line will be limited to one word, the size has been defined using a pre-processor directive to 100.
- Defined a function isLowerCase() to check if all letters in word read from file are lower case.
- Checks if position of substring is equal to positionAtWhichSubstringShouldOccur.
- If all conditions satisfied, print word.

my-diff.c
- Accepts arguments: fileName1 fileName2
- Error handling for wrong number of parameters & in case unable to open mentioned file
- Since every line can have varied length of contents, the buffer size cannot be preset and hence getline() has been used.
- Opens file using fopen() and getline() is used to read files
- While getline() is reading files, length of returned value will not be -1.
- As long as both return values (for both files) are not equal to -1, we compare them using strcmp(). If same, we move forward. If different, we check the lastPrintedLineNumber. If difference between lastPrintedLineNumber and currentLineNumber is equal to 1, we just print the different words along with arrows ( < for first file & > for second file) in different lines. If difference is greater than 1, we also print the line number before printing the words.
- If first return value of getline is equal to -1, then due to && condition, the second condition is not evaluated, therefore we need to loop over the second file till there is text available there.
- If the second return value becomes -1, the next statement of first file has already been read and therefore, that has been handled first, before reading again using a while condition.
