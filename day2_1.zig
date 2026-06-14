const std = @import("std");
const Io = std.Io;
const heap = std.heap;
const mem = std.mem;
const parseInt = std.fmt.parseInt;

const red_count = 12;
const green_count = 13;
const blue_count = 14;

pub fn main(init: std.process.Init) !void {
    var arena: heap.ArenaAllocator = .init(heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const io = init.io;
    const cwd = Io.Dir.cwd();
    const dir = try cwd.openDir(io, "./input/day2/", .{});
    const file = try dir.openFile(io, "input.txt", .{});
    defer file.close(io);
    const file_len = try file.length(io);

    var fr = file.reader(io, &.{});
    const file_content = try fr.interface.readAlloc(allocator, file_len);
    var lines = mem.splitAny(u8, file_content, "\n");

    var sum: i32 = 0;
    line: while (lines.next()) |line| {
        if (line.len == 0) { continue; }
        const line_parts = mem.cut(u8, line, ":").?;

        var sets = mem.splitAny(u8, line_parts.@"1", ";");
        while (sets.next()) |set| {
            if (set.len == 0) { continue; }

            var cubes = mem.splitAny(u8, set, ",");
            while (cubes.next()) |cube| {
                if (cube.len == 0) { continue; }

                const handfull = mem.cut(u8, mem.trim(u8, cube, " "), " ").?;
                const count = try parseInt(i32, handfull.@"0", 10);

                switch (handfull.@"1"[0]) {
                    'r' => { if (count > red_count) continue :line; },
                    'g' => { if (count > green_count) continue :line; },
                    'b' => { if (count > blue_count) continue :line; },
                    else => unreachable,
                }
            }
        }

        const game_parts = mem.cut(u8, line_parts.@"0", " ").?;
        sum += try parseInt(i32, game_parts.@"1", 10);
    }

    std.debug.print("result: {d}\n", .{sum});
}
