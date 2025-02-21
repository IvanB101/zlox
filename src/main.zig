const std = @import("std");
const chunk = @import("chunk.zig");
const value = @import("value.zig");
const vm = @import("vm.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var v = vm.VM.init(allocator);
    defer v.deinit();

    var c = chunk.Chunk.init(allocator);
    defer c.deinit();

    const idx = try c.add_constant(value.Value{ .number = 1.2 });
    try c.write(@intFromEnum(chunk.OpCode.op_constant), 14);
    try c.write(idx, 14);
    try c.write(@intFromEnum(chunk.OpCode.op_return), 20);

    try v.interpret(&c);
}
