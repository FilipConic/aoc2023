const std = @import("std");
const heap = std.heap;
const Io = std.Io;
const ascii = std.ascii;

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    const cwd = Io.Dir.cwd();
    const dir = try cwd.openDir(io, "./input/day1/", .{});
    const file: Io.File = try dir.openFile(io, "input.txt", .{});
    defer file.close(io);

    const len = try file.length(io);

    var arena: heap.ArenaAllocator = .init(heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var file_buffer: [4096]u8 = undefined;
    var fr = file.reader(io, &file_buffer);
    const file_content: []u8 = try fr.interface.readAlloc(allocator, len);

    var lines = std.mem.splitAny(u8, file_content, "\n");

    var sum: i32 = 0;
    var first: i32 = 0;
    var last: i32 = 0;
    while (lines.next()) |line| {
        for (line) |c| {
            if (ascii.isDigit(c)) {
                if (first == 0) {
                    first = c - '0';
                    last = first;
                } else {
                    last = c - '0';
                }
            }
        }
        sum += first * 10 + last;

        first = 0;
        last = 0;
    }
    std.debug.print("result: {}\n", .{sum});
}
