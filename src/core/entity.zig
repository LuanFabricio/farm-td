const utils = @import("../utils/utils.zig");

const Status = @import("status.zig").Status;

pub const Entity = struct {
    defaultStatus: Status,
    status: Status,

    pub fn copy(self: *Entity, other: Entity) void {
        self.status.copy(other.status);
        self.defaultStatus.copy(other.defaultStatus);
    }

    pub fn defaultTurret() Entity {
        const defaultStatus = Status{
            .health = 20,
            .attack = 4,
            .range = 350,
        };

        return Entity{
            .status = defaultStatus,
            .defaultStatus = defaultStatus,
        };
    }

    pub fn defaultEnemy() Entity {
        const defaultStatus = Status{
            .health = 20,
            .attack = 5,
            .range = 10,
        };

        return Entity{
            .status = defaultStatus,
            .defaultStatus = defaultStatus,
        };
    }

    // pub fn getHealthRect(self: *const Entity) utils.Rectangle {
    //     const center = self.box.getCenter();
    //     var rect = utils.Rectangle{
    //         .x = center.x,
    //         .y = center.y,
    //         .w = self.box.w,
    //         .h = 10,
    //     };
    //     const yPadding = rect.h / 2 - 15;

    //     rect.x = center.x - rect.w / 2;
    //     rect.y -= yPadding;

    //     return rect;
    // }

    pub fn healthPercentage(self: *const Entity) f32 {
        const currentHP: f32 = @floatFromInt(self.status.health);
        const defaultHP: f32 = @floatFromInt(self.defaultStatus.health);
        const percentage: f32 = currentHP / defaultHP;
        return percentage;
    }
};
