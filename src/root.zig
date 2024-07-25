const std = @import("std");
const testing = std.testing;

test {
    _ = @import("core/test_grid.zig");
    _ = @import("core/test_entity.zig");
    _ = @import("core/test_status.zig");
    _ = @import("core/test_turret.zig");
    _ = @import("core/test_enemy.zig");
    _ = @import("core/test_farm.zig");
    _ = @import("utils/test_delay.zig");
}
