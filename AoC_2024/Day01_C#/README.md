# Advent of Code 2024 – Day 1

Problem: https://adventofcode.com/2024/day/1

This document explains the reasoning and implementation behind the solutions
for **Day 1, Part 1 and Part 2** of Advent of Code 2024.

The solutions are written in **C#** and are intentionally straightforward,
prioritizing clarity and correctness over aggressive optimization.

## Overview

The input consists of multiple lines, each containing **two integers**
separated by whitespace. Conceptually, the input represents **two independent
lists of numbers**, one per column.

The task differs between Part 1 and Part 2, but both rely on the same initial
input parsing phase.

## Input Processing

The input is read from a file named `input.txt`, line by line.

For each line:
- empty or whitespace-only lines are ignored
- the line is split using whitespace as a delimiter
- the first value is appended to the `left` list
- the second value is appended to the `right` list

```csharp
List<int> left = new List<int>();
List<int> right = new List<int>();
```

---

## Part 1 Solution

After sorting both lists independently, compute the sum of the absolute
differences between corresponding elements:

Σ |left[i] − right[i]|

If the goal is to minimize or meaningfully aggregate absolute differences
between two sets of numbers, the correct greedy strategy is to sort both
lists and compare elements at the same indices.

This aligns smaller values with smaller values and larger values with larger
values.

## Implementation

Once the input has been parsed, both lists are sorted:

```csharp
left.Sort();
right.Sort();
```

The result is then computed using a single linear pass:

```csharp
for (int i = 0; i < left.Count; i++)
{
    int diff = Math.Abs(left[i] - right[i]);
    absoluteDifference += diff;
}
```
## Complexity

- Parsing: O(n)
- Sorting: O(n log n)
- Final loop: O(n)

Overall time complexity: O(n log n)
Space complexity: O(n)

---

## Part 2 Solution

For each value x in the left list:

- count how many times x appears in the right list
- multiply x by this count
- add the result to a running total

Formally:

Σ (x × occurrences_of_x_in_right)

Unlike Part 1, relative ordering is irrelevant in Part 2.
Each value in left contributes independently based solely on how often it
appears in right.

## Implementation

The solution iterates over every value in left and counts matching values
in right using a nested loop:

```csharp
for (int i = 0; i < left.Count; i++)
{
    int simCount = 0;
    for (int j = 0; j < right.Count; j++)
    {
        if (left[i] == right[j])
            simCount++;
    }
    similarityScore += simCount * left[i];
}
```

Each match increases the similarity score by the value of the matching number.

This approach directly mirrors the problem definition and avoids additional
data structures.

## Complexity

- Outer loop over left: O(n)
- Inner loop over right: O(n)
Overall time complexity: O(n²)
Space complexity: O(n)

