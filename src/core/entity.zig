const utils = @import("../utils/utils.zig");

const Status = @import("status.zig").Status;

pub const Entity = struct {
    box: utils.Rectangle,
    defaultStatus: Status,
    status: Status,

    pub fn defaultTurret(box: utils.Rectangle) Entity {
        const defaultStatus = Status{
            .health = 20,
            .attack = 4,
            .range = 350,
        };

        return Entity{
            .box = box,
            .status = defaultStatus,
            .defaultStatus = defaultStatus,
        };
    }

    pub fn defaultEnemy(box: utils.Rectangle) Entity {
        const defaultStatus = Status{
            .health = 20,
            .attack = 2,
            .range = 1,
        };

        return Entity{
            .box = box,
            .status = defaultStatus,
            .defaultStatus = defaultStatus,
        };
    }

    pub fn getHealthRect(self: *const Entity) utils.Rectangle {
        const center = self.box.getCenter();
        var rect = utils.Rectangle{
            .x = center.x,
            .y = center.y,
            .w = self.box.w,
            .h = 10,
        };
        const yPadding = rect.h / 2 - 15;

        rect.x = center.x - rect.w / 2;
        rect.y -= yPadding;

        return rect;
    }

    pub fn healthPercentage(self: *const Entity) f32 {
        const currentHP: f32 = @floatFromInt(self.status.health);
        const defaultHP: f32 = @floatFromInt(self.defaultStatus.health);
        const percentage: f32 = currentHP / defaultHP;
        return percentage;
    }
};
