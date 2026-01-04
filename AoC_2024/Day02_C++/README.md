# Advent of Code 2024 – Day 2 in C++

Problem: https://adventofcode.com/2024/day/2

This document explains the reasoning and implementation behind the solutions
for **Day 2, Part 1 and Part 2** of Advent of Code 2024.

The solutions are written in **C++** and focus on correctness and clarity,
closely following the problem definition.

## Overview

The input consists of multiple lines, each representing a **report**.
A report is a sequence of integers separated by whitespace.

Each report must be analyzed to determine whether it is considered **safe**
according to a set of rules that differ slightly between Part 1 and Part 2.

## Input Processing

The input is read from a file named `input.txt`, line by line.

Each non-empty line is processed independently using a `stringstream`
to extract the sequence of integers without storing the entire file in memory.

This allows each report to be validated incrementally.

---

## Part 1 – Solution Strategy

A report is considered **safe** if:

1. The difference between every pair of consecutive numbers is between **1 and 3**, inclusive.
2. All differences have the **same sign**, meaning the sequence is:
   - strictly increasing, or
   - strictly decreasing.

If either condition is violated, the report is unsafe.

- Only **adjacent values** matter.
- Once the direction (increasing or decreasing) is established, it must not change.
- As soon as a violation is detected, the report can be rejected immediately.

### Implementation

Each line is scanned left to right while tracking:
- the previous value
- the current trend (`+1` for decreasing, `-1` for increasing)
- a flag indicating whether the report is still safe

```cpp
long prev, x;
bool hasPrev = false;
int trend = 0;
bool safe = true;
```

For each new value:
- the absolute difference with the previous value is checked
- the sign of the difference determines the trend
- any change in trend marks the report as unsafe
If the report remains safe after processing all values, it is counted.

## Complexity

For each report of length k:
- Time complexity: O(k)
- Space complexity: O(1)
Overall complexity is linear in the size of the input.

---

## Part 2 – Solution StrategyPart 2 introduces a relaxation of the rules:

A report is considered safe if it becomes valid after removing at most one value.
This includes the case where no removal is needed.

- A single bad value can invalidate an otherwise valid sequence.
- The simplest correct approach is to try all possible single removals.
- Input sizes are small enough that a brute-force strategy is acceptable.

### Implementation

For each report:
1. Count how many values the report contains.
2. Try every possible index removal:
    - including -1, which represents removing nothing
3. For each attempt:
    - re-scan the sequence while skipping the chosen index
    - apply the same validation rules as in Part 1
4. If any attempt succeeds, the report is considered safe.

```cpp
for (int skipIdx = -1; skipIdx < len && !lineIsSafe; ++skipIdx)
{
    // simulate removing one element and re-validate
}
```

This approach avoids storing multiple copies of the data and reuses the
same validation logic from Part 1.

## Complexity

For each report of length k:
- Each validation is O(k)
- Up to k + 1 validations are performed
Worst-case time complexity per report: O(k²)
Space complexity: O(1)
