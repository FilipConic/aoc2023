const std = @import("std");
const print = std.debug.print;
const heap = std.heap;
const mem = std.mem;

pub fn main(init: std.process.Init) !void {
    var arena: heap.ArenaAllocator = .init(heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const io = init.io;

    const dir = try std.Io.Dir.cwd().openDir(io, "./input/day4/", .{});
    const file = try dir.openFile(io, "input.txt", .{});
    defer file.close(io);
    const file_len = try file.length(io);

    var fr = file.reader(io, &.{});
    const file_content = try fr.interface.readAlloc(allocator, file_len);

    var sum: u32 = 0;

    var lines = mem.splitAny(u8, file_content, "\n");
    var win = std.ArrayList(u32).empty;
    defer win.deinit(allocator);
    while (lines.next()) |line| {
        defer win.shrinkAndFree(allocator, 0);
        if (line.len == 0) { continue; }

        const parts = mem.cut(u8, mem.trim(u8, mem.cut(u8, line, ":").?.@"1", " "), "|");

        var found_count: u32 = 0;

        var nums = mem.splitAny(u8, mem.trim(u8, parts.?.@"0", " "), " ");
        while (nums.next()) |num| {
            if (num.len == 0) { continue; }
            const n = try std.fmt.parseInt(u32, mem.trim(u8, num, " "), 10);
            try win.append(allocator, n);
        }

        nums = mem.splitAny(u8, mem.trim(u8, parts.?.@"1", " "), " ");
        while (nums.next()) |num| {
            if (num.len == 0) { continue; }

            const n = try std.fmt.parseInt(u32, mem.trim(u8, num, " "), 10);
            if (mem.findScalar(u32, win.items, n)) |_| {
                found_count += 1;
            }
        }

        if (found_count != 0) {
            sum += @as(u32, 1) << @intCast(found_count - 1);
        }
    }
    print("result: {d}\n", .{sum});
}
