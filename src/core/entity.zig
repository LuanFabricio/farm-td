const utils = @import("../utils/utils.zig");

const Status = @import("status.zig").Status;

pub const Entity = struct {
    const This = @This();
    cost: u32,
    defaultStatus: Status,
    status: Status,

    pub fn copy(self: *This, other: This) void {
        self.cost = other.cost;
        self.status.copy(other.status);
        self.defaultStatus.copy(other.defaultStatus);
    }

    pub fn defaultTurret() This {
        const defaultStatus = Status{
            .health = 20,
            .attack = 4,
            .range = 350,
        };

        return This{
            .cost = 42,
            .status = defaultStatus,
            .defaultStatus = defaultStatus,
        };
    }

    pub fn defaultEnemy() This {
        const defaultStatus = Status{
            .health = 20,
            .attack = 5,
            .range = 10,
        };

        return This{
            .cost = 0,
            .status = defaultStatus,
            .defaultStatus = defaultStatus,
        };
    }

    pub fn healthPercentage(self: *const This) f32 {
        const currentHP: f32 = @floatFromInt(self.status.health);
        const defaultHP: f32 = @floatFromInt(self.defaultStatus.health);
        const percentage: f32 = currentHP / defaultHP;
        return percentage;
    }
};
