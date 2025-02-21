const std = @import("std");
const build_options = @import("build_options");

const Chunk = @import("chunk.zig").Chunk;
const OpCode = @import("chunk.zig").OpCode;
const Value = @import("value.zig").Value;

pub const InterpretError = error{
    Compile,
    Runtime,
};

pub const VM = struct {
    const Self = @This();
    chunk: ?*Chunk,
    ip: ?*u8,
    stack: std.ArrayList(Value),

    pub fn interpret(self: *Self, chunk: *Chunk) InterpretError!void {
        self.chunk = chunk;
        self.ip = &chunk.code.items[0];

        return self.run();
    }

    inline fn read_byte(self: *Self) u8 {
        const instruction = self.ip.?.*;
        self.ip = @ptrFromInt(@intFromPtr(self.ip.?) + 1);
        return instruction;
    }

    inline fn read_constant(self: *Self) Value {
        return self.chunk.?.constants.items[self.read_byte()];
    }

    fn run(self: *Self) InterpretError!void {
        var instruction: OpCode = undefined;
        while (true) {
            if (build_options.execution_trace) {
                self.chunk.?.dissamsembleInstruction(@intFromPtr(self.ip.?) - @intFromPtr(&self.chunk.?.code.items[0]));
            }

            instruction = @enumFromInt(self.read_byte());
            switch (instruction) {
                OpCode.op_return => {
                    return;
                },
                OpCode.op_constant => {
                    const val = self.read_constant();
                    val.print();
                    std.debug.print("\n", .{});
                },
            }
        }
    }

    pub fn init(allocator: std.mem.Allocator) VM {
        return .{ .chunk = null, .ip = null, .stack = std.ArrayList(Value).init(allocator) };
    }

    pub fn deinit(self: *Self) void {
        self.chunk = null;
    }
};
