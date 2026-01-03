/*
https://adventofcode.com/2024/day/4
To run it, use the command: rustc Day4_2.rs && ./Day4_2 < input.txt
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

    // corners around (x,y=A) in order: NW, NE, SE, SW
    let corners: [(isize, isize); 4] = [(-1, -1), (1, -1), (1, 1), (-1, 1)];

    // Valid corner sequences (NW, NE, SE, SW)
    let valid: [[u8; 4]; 4] = [
        [b'M', b'M', b'S', b'S'],
        [b'M', b'S', b'S', b'M'],
        [b'S', b'S', b'M', b'M'],
        [b'S', b'M', b'M', b'S'],
    ];


    let mut count = 0i64;

    // If A is on the border, it can't have all four corners.
    for y in 1..(h - 1) {
        for x in 1..(w - 1) {
            if grid[y as usize][x as usize] != b'A' {
                continue;
            }
            let mut seq = [0u8; 4];
            for (i, (dx, dy)) in corners.iter().enumerate() {
                let nx = x + dx;
                let ny = y + dy;
                seq[i] = grid[ny as usize][nx as usize];
            }
            if valid.iter().any(|v| *v == seq) {
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
