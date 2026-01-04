// https://adventofcode.com/2024/day/11
// To run it, use the command: zig run Day11_1.zig < input.txt

const std = @import("std");

fn numDigits(n: u64) u32 {
    // n is never 0 when this is called in our rules (we special-case 0),
    // but let's keep it correct anyway.
    var x = n;
    var d: u32 = 1;
    while (x >= 10) : (x /= 10) d += 1;
    return d;
}

fn pow10(exp: u32) u64 {
    var p: u64 = 1;
    var i: u32 = 0;
    while (i < exp) : (i += 1) p *= 10;
    return p;
}

fn addCount(map: *std.AutoHashMap(u64, u64), key: u64, delta: u64) !void {
    if (map.getPtr(key)) |ptr| {
        ptr.* += delta;
    } else {
        try map.put(key, delta);
    }
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    // Read entire stdin
    const stdin = std.io.getStdIn().reader();
    const input = try stdin.readAllAlloc(allocator, 10 * 1024 * 1024);
    defer allocator.free(input);

    // Parse numbers separated by whitespace
    var counts = std.AutoHashMap(u64, u64).init(allocator);
    defer counts.deinit();

    var it = std.mem.tokenizeAny(u8, input, " \n\r\t");
    while (it.next()) |tok| {
        const v = try std.fmt.parseUnsigned(u64, tok, 10);
        try addCount(&counts, v, 1);
    }

    // Perform 25 blinks
    var step: u32 = 0;
    while (step < 25) : (step += 1) {
        var next = std.AutoHashMap(u64, u64).init(allocator);

        var iter = counts.iterator();
        while (iter.next()) |entry| {
            const value = entry.key_ptr.*;
            const c = entry.value_ptr.*;

            if (value == 0) {
                try addCount(&next, 1, c);
                continue;
            }

            const d = numDigits(value);
            if (d % 2 == 0) {
                const half = d / 2;
                const div = pow10(half);
                const left = value / div;
                const right = value % div;
                try addCount(&next, left, c);
                try addCount(&next, right, c);
            } else {
                // u64 is enough for Part 1 inputs in practice
                const newv = value * 2024;
                try addCount(&next, newv, c);
            }
        }

        counts.deinit();
        counts = next;
    }

    // Sum all counts
    var total: u64 = 0;
    var iter2 = counts.iterator();
    while (iter2.next()) |entry| {
        total += entry.value_ptr.*;
    }

    const stdout = std.io.getStdOut().writer();
    try stdout.print("{d}\n", .{total});
}

