// https://adventofcode.com/2024/day/8
// To run it, use the command: go run day8_1.go < input.txt

package main

import (
	"bufio"
	"fmt"
	"os"
)

type Point struct {
	r int
	c int
}

func main() {
	// Read grid from stdin
	sc := bufio.NewScanner(os.Stdin)
	grid := make([][]rune, 0)

	for sc.Scan() {
		line := sc.Text()
		if len(line) == 0 {
			continue
		}
		grid = append(grid, []rune(line))
	}
	if err := sc.Err(); err != nil {
		fmt.Fprintln(os.Stderr, "read error:", err)
		os.Exit(1)
	}
	if len(grid) == 0 {
		fmt.Println(0)
		return
	}

	H := len(grid)
	W := len(grid[0])

	// Collect antenna locations by frequency rune
	antennas := make(map[rune][]Point)
	for r := 0; r < H; r++ {
		// (AoC inputs are rectangular; this is defensive)
		if len(grid[r]) != W {
			W = min(W, len(grid[r]))
		}
		for c := 0; c < W; c++ {
			ch := grid[r][c]
			if ch != '.' {
				antennas[ch] = append(antennas[ch], Point{r, c})
			}
		}
	}

	// Set of antinode points (unique)
	antinodes := make(map[Point]struct{})

	inBounds := func(p Point) bool {
		return p.r >= 0 && p.r < H && p.c >= 0 && p.c < W
	}

	// For each frequency group, consider all pairs
	for _, pts := range antennas {
		n := len(pts)
		for i := 0; i < n; i++ {
			for j := i + 1; j < n; j++ {
				p := pts[i]
				q := pts[j]

				// antinode1 = 2p - q
				a1 := Point{r: 2*p.r - q.r, c: 2*p.c - q.c}
				// antinode2 = 2q - p
				a2 := Point{r: 2*q.r - p.r, c: 2*q.c - p.c}

				if inBounds(a1) {
					antinodes[a1] = struct{}{}
				}
				if inBounds(a2) {
					antinodes[a2] = struct{}{}
				}
			}
		}
	}

	fmt.Println(len(antinodes))
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}
