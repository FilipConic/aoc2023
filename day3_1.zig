const std = @import("std");
const heap = std.heap;
const Io = std.Io;
const mem = std.mem;
const array_list = std.array_list;
const ArrayList = std.ArrayList;
const ascii = std.ascii;
const maxInt = std.math.maxInt;

const State = enum {
    Start,
    StartReadingNum,
    ReadingNum,
    EndReadingNum,
    None,
    End,
};
const Field = struct {
    ptr: ?[]i16 = null,
    width: usize = 0,
    height: usize = 0,
    
    numbers: ArrayList(i32),
};

pub fn main(init: std.process.Init) !void {
    var arena: heap.ArenaAllocator = .init(heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const io = init.io;
    const cwd = Io.Dir.cwd();
    const dir = try cwd.openDir(io, "./input/day3/", .{});
    const file = try dir.openFile(io, "./input.txt", .{});
    const file_len = try file.length(io);

    var fr = file.reader(io, &.{});
    const file_content = try fr.interface.readAlloc(allocator, file_len);

    var lines = mem.splitAny(u8, file_content, "\n");
    var field = Field{
        .numbers = ArrayList(i32).empty,
    };

    while (lines.next()) |line| {
        if (line.len == 0) { continue; }

        var state = State.Start;
        var i: usize = 0;
        var start_reading: usize = 0;
        state = ret: switch (state) {
            .Start => {
                if (ascii.isDigit(line[i])) {
                    continue :ret .StartReadingNum;
                }
                continue :ret .None;
            },
            .StartReadingNum => {
                start_reading = i;
                continue :ret .ReadingNum;
            },
            .EndReadingNum => {
                const num = try std.fmt.parseInt(i32, line[start_reading..i], 10);
                _ = try field.numbers.append(allocator, num);

                if (i == line.len) { break :ret .End; }
                continue :ret .None;
            },
            .None => {
                i += 1;
                if (i == line.len) { break :ret .End; }

                if (ascii.isDigit(line[i])) {
                    continue :ret .StartReadingNum;
                }
                continue :ret .None;
            },
            .ReadingNum => {
                i += 1;
                if (i == line.len) { continue :ret .EndReadingNum; }

                if (ascii.isDigit(line[i])) {
                    continue :ret .ReadingNum;
                }
                continue :ret .EndReadingNum;
            },
            .End => { break :ret .End; },
        };

        field.width = line.len;
        field.height += 1;
    }

    field.ptr = try allocator.alloc(i16, field.width * field.height);
    lines = mem.splitAny(u8, file_content, "\n");

    var curr_num: i16 = 0;
    var j: usize = 0;
    while (lines.next()) |line| {
        if (line.len == 0) { continue; }

        var state = State.Start;
        var i: usize = 0;
        state = ret: switch (state) {
            .Start => {
                if (ascii.isDigit(line[i])) {
                    continue :ret .StartReadingNum;
                }
                continue :ret .None;
            },
            .StartReadingNum => {
                continue :ret .ReadingNum;
            },
            .EndReadingNum => {
                curr_num += 1;
                if (i == line.len) { continue :ret .End; }
                if (curr_num >= maxInt(i16)) unreachable;
                continue :ret .None;
            },
            .None => {
                if (line[i] == '.') {
                    field.ptr.?[i + j * field.width] = -1;
                } else {
                    field.ptr.?[i + j * field.width] = -2;
                }

                i += 1;
                if (i == line.len) { break :ret .End; }

                if (ascii.isDigit(line[i])) {
                    continue :ret .StartReadingNum;
                }
                continue :ret .None;
            },
            .ReadingNum => {
                field.ptr.?[i + j * field.width] = curr_num;

                i += 1;
                if (i == line.len) { continue :ret .EndReadingNum; }

                if (ascii.isDigit(line[i])) {
                    continue :ret .ReadingNum;
                }
                continue :ret .EndReadingNum;
            },
            .End => { break :ret .End; },
        };
        j += 1;
    }

    var sum: i32 = 0;
    for (0..field.height) |y| {
        for (0..field.width) |x| {
            const n = field.ptr.?[x + y * field.width];
            if (n != -2) { continue; }

            var i: usize = 0;
            var square: [9]i16 = @splat(-1);
            for (@max(0, y -| 1)..@min(field.height, y + 2)) |yy| {
                for (@max(0, x -| 1)..@min(field.width, x + 2)) |xx| {
                    square[i] = field.ptr.?[xx + yy * field.width];
                    i += 1;
                }
            }
            sum += addSmallSquare(square, field.numbers);
        }
    }

    std.debug.print("result: {}\n", .{sum});
}

fn addSmallSquare(square: [9]i16, vals: ArrayList(i32)) i32 {
    var added: [8]i16 = @splat(-1);
    var addedCount: usize = 0;

    var sum: i32 = 0;
    for (square) |num| {
        if (num < 0) { continue; }
        if (mem.findScalar(i16, &added, num)) |_| { continue; }

        if (addedCount >= 8) { unreachable; }
        added[addedCount] = num;
        addedCount += 1;

        sum += vals.items[@intCast(num)];
    }
    return sum;
}
