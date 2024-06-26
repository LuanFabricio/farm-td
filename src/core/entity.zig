const utils = @import("../utils/utils.zig");

const Status = @import("status.zig").Status;

pub const Entity = struct {
    box: utils.Rectangle,
    defaultStatus: Status,
    status: Status,

    pub fn defaultTurret(box: utils.Rectangle) Entity {
        const defaultStatus = Status{
            .health = 20,
            .attack = 40,
            .range = 3,
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
            .attack = 40,
            .range = 1,
        };

        return Entity{
            .box = box,
            .status = defaultStatus,
            .defaultStatus = defaultStatus,
        };
    }
};
