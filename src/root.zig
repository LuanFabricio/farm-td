const std = @import("std");
const testing = std.testing;

test {
    _ = @import("core/test_game.zig");
    _ = @import("core/test_grid.zig");
    _ = @import("core/test_entity.zig");
    _ = @import("core/test_status.zig");
    _ = @import("core/test_turret.zig");
    _ = @import("core/test_enemy.zig");
    _ = @import("core/test_farm.zig");
    _ = @import("utils/test_delay.zig");
    _ = @import("utils/test_utils_rectangle.zig");
    _ = @import("utils/test_utils_point.zig");
    _ = @import("utils/test_utils_color.zig");
    _ = @import("core/collision/test_hitbox.zig");
    _ = @import("core/collision/test_function.zig");
}
