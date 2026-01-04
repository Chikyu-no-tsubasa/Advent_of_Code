// https://adventofcode.com/2024/day/8
// To run it, use the command: go run day8_2.go < input.txt

package main

import (
	"bufio"
	"fmt"
	"os"
)

type Point struct {
	x, y int
}

func abs(a int) int {
	if a < 0 {
		return -a
	}
	return a
}

func gcd(a, b int) int {
	a = abs(a)
	b = abs(b)
	for b != 0 {
		a, b = b, a%b
	}
	if a == 0 {
		return 1
	}
	return a
}

func inBounds(p Point, w, h int) bool {
	return p.x >= 0 && p.x < w && p.y >= 0 && p.y < h
}

func main() {
	// Read whole input (grid)
	sc := bufio.NewScanner(os.Stdin)
	// Safe buffer for typical AoC line lengths
	sc.Buffer(make([]byte, 1024), 1024*1024)

	var lines []string
	for sc.Scan() {
		line := sc.Text()
		if len(line) > 0 {
			lines = append(lines, line)
		}
	}
	if err := sc.Err(); err != nil {
		fmt.Fprintln(os.Stderr, "read error:", err)
		os.Exit(1)
	}
	if len(lines) == 0 {
		fmt.Println(0)
		return
	}

	h := len(lines)
	w := len(lines[0])

	// Collect antenna locations by frequency character
	antennas := make(map[rune][]Point)
	for y := 0; y < h; y++ {
		row := []rune(lines[y])
		for x := 0; x < w; x++ {
			ch := row[x]
			if ch != '.' {
				antennas[ch] = append(antennas[ch], Point{x: x, y: y})
			}
		}
	}

	// Set of antinode positions, encoded as y*w + x
	antinodes := make(map[int]struct{})

	add := func(p Point) {
		antinodes[p.y*w+p.x] = struct{}{}
	}

	// For each frequency group, for each pair, mark all points on the line
	for _, pts := range antennas {
		n := len(pts)
		if n < 2 {
			continue
		}
		for i := 0; i < n-1; i++ {
			for j := i + 1; j < n; j++ {
				p1 := pts[i]
				p2 := pts[j]

				dx := p2.x - p1.x
				dy := p2.y - p1.y

				// Reduce direction to the smallest integer step along the line
				g := gcd(dx, dy)
				sx := dx / g
				sy := dy / g

				// Walk backwards from p1 (includes p1)
				cur := p1
				for inBounds(cur, w, h) {
					add(cur)
					cur = Point{x: cur.x - sx, y: cur.y - sy}
				}

				// Walk forwards from p1+step (to avoid adding p1 twice)
				cur = Point{x: p1.x + sx, y: p1.y + sy}
				for inBounds(cur, w, h) {
					add(cur)
					cur = Point{x: cur.x + sx, y: cur.y + sy}
				}
			}
		}
	}

	fmt.Println(len(antinodes))
}
