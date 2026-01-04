// https://adventofcode.com/2024/day/9
// To run it, use the command: gcc -O2 -std=c11 Day9_2.c -o Day9_2
// ./Day9_2 < input.txt

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

typedef long long ll;

typedef struct {
    int id;
    ll start;
    ll len;
} FileSeg;

typedef struct FreeSeg {
    ll start;
    ll len;
    struct FreeSeg *next;
} FreeSeg;

static void die(const char *msg) {
    perror(msg);
    exit(1);
}

static FreeSeg* new_free(ll start, ll len) {
    FreeSeg *n = (FreeSeg*)malloc(sizeof(FreeSeg));
    if (!n) die("malloc");
    n->start = start;
    n->len = len;
    n->next = NULL;
    return n;
}

// Insert a free segment into the sorted free-list and merge with neighbors if adjacent.
static void insert_and_merge_free(FreeSeg **head, ll start, ll len) {
    if (len <= 0) return;

    FreeSeg *prev = NULL, *cur = *head;

    // Find insertion point (sorted by start)
    while (cur && cur->start < start) {
        prev = cur;
        cur = cur->next;
    }

    FreeSeg *node = new_free(start, len);

    node->next = cur;
    if (prev) prev->next = node;
    else *head = node;

    // Merge with previous if adjacent
    if (prev && (prev->start + prev->len == node->start)) {
        prev->len += node->len;
        prev->next = node->next;
        free(node);
        node = prev;
    }

    // Merge with next if adjacent
    FreeSeg *next = node->next;
    if (next && (node->start + node->len == next->start)) {
        node->len += next->len;
        node->next = next->next;
        free(next);
    }
}

// Find the leftmost free segment that:
// - starts < fileStart
// - has len >= need
// Return prev + seg for in-place update/removal.
static void find_fitting_free(FreeSeg *head, ll fileStart, ll need, FreeSeg **outPrev, FreeSeg **outSeg) {
    FreeSeg *prev = NULL;
    FreeSeg *cur = head;

    while (cur && cur->start < fileStart) {
        if (cur->len >= need) {
            *outPrev = prev;
            *outSeg = cur;
            return;
        }
        prev = cur;
        cur = cur->next;
    }
    *outPrev = NULL;
    *outSeg = NULL;
}

// Robustly read a full line (handles very long input).
static char* read_line_stdin(void) {
    size_t cap = 1024;
    size_t len = 0;
    char *buf = (char*)malloc(cap);
    if (!buf) die("malloc");

    int c;
    while ((c = fgetc(stdin)) != EOF) {
        if (c == '\n') break;
        if (len + 1 >= cap) {
            cap *= 2;
            char *nb = (char*)realloc(buf, cap);
            if (!nb) die("realloc");
            buf = nb;
        }
        buf[len++] = (char)c;
    }

    if (c == EOF && len == 0) {
        free(buf);
        return NULL;
    }

    buf[len] = '\0';
    // strip trailing \r if present
    if (len > 0 && buf[len-1] == '\r') buf[len-1] = '\0';
    return buf;
}

int main(void) {
    char *s = read_line_stdin();
    if (!s) return 0;

    size_t n = strlen(s);

    // Count digits (ignore any stray whitespace)
    size_t dcount = 0;
    for (size_t i = 0; i < n; i++) {
        if (isdigit((unsigned char)s[i])) dcount++;
    }

    if (dcount == 0) {
        printf("0\n");
        free(s);
        return 0;
    }

    // Files = ceil(dcount/2)
    size_t fileCount = (dcount + 1) / 2;
    FileSeg *files = (FileSeg*)calloc(fileCount, sizeof(FileSeg));
    if (!files) die("calloc");

    // Build file segments and free segment list
    ll pos = 0;
    int fileId = 0;
    int isFile = 1;

    FreeSeg *freeHead = NULL;
    FreeSeg *freeTail = NULL;

    for (size_t i = 0; i < n; i++) {
        if (!isdigit((unsigned char)s[i])) continue;
        int len = s[i] - '0';

        if (isFile) {
            files[fileId].id = fileId;
            files[fileId].start = pos;
            files[fileId].len = (ll)len;
            fileId++;
        } else {
            if (len > 0) {
                FreeSeg *node = new_free(pos, (ll)len);
                if (!freeHead) freeHead = node;
                else freeTail->next = node;
                freeTail = node;
            }
        }

        pos += (ll)len;
        isFile = !isFile;
    }

    int maxId = (int)fileCount - 1;

    // Move whole files, descending id
    for (int id = maxId; id >= 0; id--) {
        FileSeg *f = &files[id];
        if (f->len == 0) continue; // zero-length file: ignore

        FreeSeg *prev = NULL, *seg = NULL;
        find_fitting_free(freeHead, f->start, f->len, &prev, &seg);
        if (!seg) continue; // no space to the left that fits

        ll newStart = seg->start;
        ll oldStart = f->start;

        // Consume from the left side of the free segment
        seg->start += f->len;
        seg->len   -= f->len;

        // If segment is now empty, remove it
        if (seg->len == 0) {
            if (prev) prev->next = seg->next;
            else freeHead = seg->next;

            // tail maintenance (optional)
            if (freeTail == seg) freeTail = prev;

            free(seg);
        }

        // Update file to its new location
        f->start = newStart;

        // Old file location becomes free space (insert and merge)
        insert_and_merge_free(&freeHead, oldStart, f->len);

        // Recompute tail (keeps tail sane, not strictly required)
        freeTail = freeHead;
        while (freeTail && freeTail->next) freeTail = freeTail->next;
    }

    // Compute checksum from segments:
    // sum over blocks in segment: (sum positions) * id
    ll checksum = 0;
    for (size_t i = 0; i < fileCount; i++) {
        ll L = files[i].len;
        if (L <= 0) continue;

        ll first = files[i].start;
        ll last  = files[i].start + L - 1;
        ll sumPos = (first + last) * L / 2;  // arithmetic series sum
        checksum += sumPos * (ll)files[i].id;
    }

    printf("%lld\n", checksum);

    // Cleanup
    FreeSeg *cur = freeHead;
    while (cur) {
        FreeSeg *nx = cur->next;
        free(cur);
        cur = nx;
    }
    free(files);
    free(s);
    return 0;
}
