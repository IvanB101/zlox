const std = @import("std");
const chunk = @import("chunk.zig");
const value = @import("value.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var c = chunk.Chunk.init(allocator);

    const idx = try c.add_constant(value.Value{ .number = 1.2 });
    try c.write(@intFromEnum(chunk.OpCode.op_constant), 14);
    try c.write(idx, 14);

    try c.write(@intFromEnum(chunk.OpCode.op_return), 20);

    c.dissamsemble("Test chunk");
}
