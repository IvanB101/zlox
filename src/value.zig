const std = @import("std");

pub const ValueType = enum {
    number,
};

pub const Value = union(ValueType) {
    number: f64,

    pub fn print_value(self: @This()) void {
        switch (self) {
            .number => |value| {
                std.debug.print("{d: <20}", .{value});
            },
        }
    }
};
