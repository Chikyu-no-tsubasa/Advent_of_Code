// https://adventofcode.com/2024/day/9
// To run it, use the command: gcc -O2 -std=c11 Day9_1.c -o Day9_1
// ./Day9_1 < input.txt

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

int main(void) {
    // Read the single input line (can be long)
    // We'll allocate a big buffer; AoC inputs are not gigantic.
    size_t cap = 200000;
    char *s = (char *)malloc(cap);
    if (!s) return 1;

    if (!fgets(s, (int)cap, stdin)) {
        free(s);
        return 0;
    }

    // Strip trailing newline
    size_t n = strlen(s);
    while (n > 0 && (s[n-1] == '\n' || s[n-1] == '\r')) {
        s[--n] = '\0';
    }

    // First pass: total number of disk blocks = sum of all digits
    long totalBlocks = 0;
    for (size_t i = 0; i < n; i++) {
        if (!isdigit((unsigned char)s[i])) continue;
        totalBlocks += (s[i] - '0');
    }

    // Expand disk into an int array:
    // file blocks store their file ID, free blocks store -1
    int *disk = (int *)malloc((size_t)totalBlocks * sizeof(int));
    if (!disk) {
        free(s);
        return 1;
    }

    long pos = 0;
    int fileId = 0;
    int isFile = 1; // starts with file length

    for (size_t i = 0; i < n; i++) {
        if (!isdigit((unsigned char)s[i])) continue;
        int len = s[i] - '0';

        if (isFile) {
            for (int k = 0; k < len; k++) disk[pos++] = fileId;
            fileId++;
        } else {
            for (int k = 0; k < len; k++) disk[pos++] = -1;
        }

        isFile = !isFile;
    }

    // Compact in-place using two pointers:
    // left -> first free spot
    // right -> last file block
    long left = 0;
    long right = totalBlocks - 1;

    while (1) {
        while (left < totalBlocks && disk[left] != -1) left++;
        while (right >= 0 && disk[right] == -1) right--;

        if (left >= right) break;

        // move one block from the end to the leftmost hole
        disk[left] = disk[right];
        disk[right] = -1;
        left++;
        right--;
    }

    // Compute checksum
    long long checksum = 0;
    for (long i = 0; i < totalBlocks; i++) {
        if (disk[i] != -1) {
            checksum += (long long)i * (long long)disk[i];
        }
    }

    printf("%lld\n", checksum);

    free(disk);
    free(s);
    return 0;
}
