const std = @import("std");
const testing = std.testing;

export fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "basic add functionality" {
    try testing.expect(add(3, 7) == 10);
}

test {
    _ = @import("core/test_grid.zig");
    _ = @import("core/test_entity.zig");
    _ = @import("core/test_status.zig");
    _ = @import("core/test_turret.zig");
}
