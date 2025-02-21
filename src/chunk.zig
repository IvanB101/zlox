const std = @import("std");
const value = @import("value.zig");

const ChunkError = error{
    TooManyConstants,
};

pub const OpCode = enum(u8) {
    op_constant,
    op_return,

    fn get_name(idx: u8) []const u8 {
        if (idx < std.enums.values(OpCode).len) {
            return @tagName(std.enums.values(OpCode)[idx]);
        } else {
            return "Unknown opcode";
        }
    }
};

pub const Chunk = struct {
    const Self = @This();

    code: std.ArrayList(u8),
    lines: std.ArrayList(usize),
    constants: std.ArrayList(value.Value),

    pub fn init(alloc: std.mem.Allocator) Self {
        return .{ .code = std.ArrayList(u8).init(alloc), .lines = std.ArrayList(usize).init(alloc), .constants = std.ArrayList(value.Value).init(alloc) };
    }

    pub fn write(self: *Self, byte: u8, line: usize) !void {
        try self.code.append(byte);

        while (line > self.lines.items.len) {
            try self.lines.append(0);
        }

        self.lines.items[self.lines.items.len - 1] += 1;
    }

    pub fn add_constant(self: *Self, constant: value.Value) !u8 {
        if (self.constants.items.len >= 255) {
            return ChunkError.TooManyConstants;
        }

        try self.constants.append(constant);
        return @intCast(self.constants.items.len - 1);
    }

    pub fn deinit(self: *Self) void {
        self.code.deinit();
        self.lines.deinit();
        self.constants.deinit();
    }

    pub fn get_line(self: *const Self, offset: usize) usize {
        var line: usize = 0;
        var sum: usize = 0;

        while (sum <= offset) {
            sum += self.lines.items[line];
            line += 1;
        }

        return line;
    }

    pub fn iter(self: *const Self) InstructionIterator {
        return .{
            .chunk = self,
            .offset = 0,
            .line = 0,
        };
    }

    pub fn dissamsemble(self: *const Self, name: ?[]const u8) void {
        std.debug.print("=== {s} ===", .{name});
        var iterator = self.iter();

        while (iterator.next()) |_| {
            self.dissamsembleInstruction(iterator.get_offset());
        }
    }

    pub fn dissamsembleInstruction(self: *const Self, offset: usize) void {
        const int_code = self.code.items[offset];
        const instruction: OpCode = @enumFromInt(int_code);

        std.debug.print("{d:0>4} {d: >5} {s: <20}", .{ offset, self.get_line(offset), OpCode.get_name(int_code) });

        switch (instruction) {
            .op_constant => {
                const idx = self.code.items[offset + 1];
                self.constants.items[idx].print();
            },
            else => {},
        }

        std.debug.print("\n", .{});
    }
};

pub const InstructionIterator = struct {
    const Self = @This();
    chunk: *Chunk,
    offset: usize,

    pub fn has_next(self: *const Self) bool {
        return self.offset < self.chunk.code.items.len;
    }

    pub fn get_offset(self: *const Self) usize {
        return self.offset;
    }

    pub fn next(self: *Self) ?OpCode {
        if (!self.offset < self.chunk.code.items.len) {
            return null;
        }

        const instruction: OpCode = @enumFromInt(self.chunk.code.items[self.offset]);

        switch (instruction) {
            .op_constant => {
                self.offset += 2;
            },
            else => {
                self.offset += 1;
            },
        }

        return instruction;
    }
};
