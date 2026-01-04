/*
https://adventofcode.com/2024/day/4
To run it, use the command: rustc Day4_1.rs && ./Day4_1 < input.txt
*/
use std::io::{self, Read};

const DIRS_8: [(isize, isize); 8] = [
    (-1, -1), (-1, 0), (-1, 1),
    ( 0, -1),          ( 0, 1),
    ( 1, -1), ( 1, 0), ( 1, 1),
];

fn in_bounds(x: isize, y: isize, w: isize, h: isize) -> bool {
    x >= 0 && x < w && y >= 0 && y < h
}

fn res(grid: &[Vec<u8>]) -> i64 {
    let h = grid.len() as isize;
    let w = grid[0].len() as isize;
    let word = *b"XMAS";
    let mut count = 0i64;

    for y in 0..h {
        for x in 0..w {
            if grid[y as usize][x as usize] != b'X' {
                continue;
            }
            'dirloop: for (dx, dy) in DIRS_8 {
                for i in 0..(word.len() as isize) {
                    let nx = x + dx * i;
                    let ny = y + dy * i;
                    if !in_bounds(nx, ny, w, h) {
                        continue 'dirloop;
                    }
                    if grid[ny as usize][nx as usize] != word[i as usize] {
                        continue 'dirloop;
                    }
                }
                count += 1;
            }
        }
    }
    count
}

fn main() {
    let mut input = String::new();
    io::stdin().read_to_string(&mut input).unwrap();

    let lines: Vec<&str> = input.lines().filter(|l| !l.trim().is_empty()).collect();
    let grid: Vec<Vec<u8>> = lines.iter().map(|l| l.as_bytes().to_vec()).collect();

    let r = res(&grid);

    println!("Res: {}", r);
}
