// https://adventofcode.com/2024/day/11
// To run it, use the command: zig run Day11_2.zig < input.txt
const std = @import("std");

fn normalizeDec(alloc: std.mem.Allocator, s: []const u8) ![]const u8 {
    // Remove leading zeros, but keep a single "0" if the number is all zeros.
    var i: usize = 0;
    while (i < s.len and s[i] == '0') : (i += 1) {}
    if (i == s.len) {
        return try alloc.dupe(u8, "0");
    }
    return try alloc.dupe(u8, s[i..]);
}

fn mulSmallDec(alloc: std.mem.Allocator, s: []const u8, m: u32) ![]const u8 {
    if (s.len == 1 and s[0] == '0') return try alloc.dupe(u8, "0");

    var buf = try alloc.alloc(u8, s.len + 8);
    var out_i: usize = buf.len;

    var carry: u64 = 0;
    var idx: isize = @as(isize, @intCast(s.len)) - 1;

    while (idx >= 0) : (idx -= 1) {
        const ch = s[@as(usize, @intCast(idx))];
        const digit: u64 = @intCast(ch - '0');
        const prod: u64 = digit * @as(u64, m) + carry;
        const out_digit: u8 = @intCast(prod % 10);
        carry = prod / 10;

        out_i -= 1;
        buf[out_i] = out_digit + '0';
    }

    while (carry > 0) {
        out_i -= 1;
        buf[out_i] = @intCast((carry % 10) + '0');
        carry /= 10;
    }

    const raw = buf[out_i..];
    const res = try alloc.dupe(u8, raw);
    alloc.free(buf);
    defer alloc.free(res);

    return normalizeDec(alloc, res);
}

fn addCount(map: *std.StringHashMap(u128), key: []const u8, delta: u128) !void {
    if (map.getPtr(key)) |ptr| {
        ptr.* += delta;
    } else {
        try map.put(key, delta);
    }
}

pub fn main() !void {
    const gpa = std.heap.page_allocator;

    // Read stdin
    const stdin = std.io.getStdIn().reader();
    const input = try stdin.readAllAlloc(gpa, 20 * 1024 * 1024);
    defer gpa.free(input);

    // Two arenas we alternate each blink:
    // - current arena owns current map's keys
    // - next arena owns next map's keys
    var arena_a = std.heap.ArenaAllocator.init(gpa);
    defer arena_a.deinit();
    var arena_b = std.heap.ArenaAllocator.init(gpa);
    defer arena_b.deinit();

    var cur_arena = &arena_a;
    var next_arena = &arena_b;

    var counts = std.StringHashMap(u128).init(cur_arena.allocator());
    defer counts.deinit();

    // Parse input stones into counts map
    var it = std.mem.tokenizeAny(u8, input, " \n\r\t");
    while (it.next()) |tok| {
        const norm = try normalizeDec(cur_arena.allocator(), tok);
        try addCount(&counts, norm, 1);
    }

    // 75 blinks for Part 2
    var step: u32 = 0;
    while (step < 75) : (step += 1) {
        // reset next arena for fresh allocations
        _ = next_arena.reset(.retain_capacity);

        var next = std.StringHashMap(u128).init(next_arena.allocator());

        var iter = counts.iterator();
        while (iter.next()) |entry| {
            const value = entry.key_ptr.*;   // string slice
            const c = entry.value_ptr.*;     // u128 count

            if (value.len == 1 and value[0] == '0') {
                const one = try next_arena.allocator().dupe(u8, "1");
                try addCount(&next, one, c);
                continue;
            }

            if (value.len % 2 == 0) {
                const half = value.len / 2;

                const left_raw = value[0..half];
                const right_raw = value[half..];

                const left = try normalizeDec(next_arena.allocator(), left_raw);
                const right = try normalizeDec(next_arena.allocator(), right_raw);

                try addCount(&next, left, c);
                try addCount(&next, right, c);
            } else {
                const prod = try mulSmallDec(next_arena.allocator(), value, 2024);
                try addCount(&next, prod, c);
            }
        }

        counts.deinit();
        counts = next;

        // swap arenas: next becomes current for the next iteration
        const tmp = cur_arena;
        cur_arena = next_arena;
        next_arena = tmp;
    }

    // Sum counts
    var total: u128 = 0;
    var iter2 = counts.iterator();
    while (iter2.next()) |entry| {
        total += entry.value_ptr.*;
    }

    const stdout = std.io.getStdOut().writer();
    try stdout.print("{d}\n", .{total});
}
