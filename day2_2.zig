const std = @import("std");
const Io = std.Io;
const heap = std.heap;
const mem = std.mem;
const parseInt = std.fmt.parseInt;
const maxInt = std.math.maxInt;

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
    while (lines.next()) |line| {
        if (line.len == 0) { continue; }
        const line_parts = mem.cut(u8, line, ":").?;

        var sets = mem.splitAny(u8, line_parts.@"1", ";");

        var min_red: i32 = 0;
        var min_green: i32 = 0;
        var min_blue: i32 = 0;
        while (sets.next()) |set| {
            if (set.len == 0) { continue; }

            var cubes = mem.splitAny(u8, set, ",");

            while (cubes.next()) |cube| {
                if (cube.len == 0) { continue; }

                const handfull = mem.cut(u8, mem.trim(u8, cube, " "), " ").?;
                const count = try parseInt(i32, handfull.@"0", 10);

                switch (handfull.@"1"[0]) {
                    'r' => { if (count > min_red) min_red = count; },
                    'g' => { if (count > min_green) min_green = count; },
                    'b' => { if (count > min_blue) min_blue = count; },
                    else => unreachable,
                }
            }
        }
        sum += min_red * min_green * min_blue;
    }

    std.debug.print("result: {d}\n", .{sum});
}
