const utils = @import("../utils/utils.zig");

const Entity = @import("entity.zig").Entity;

pub const DEFAULT_COLOR = utils.Color{
    .r = 0x19,
    .g = 0xff,
    .b = 0x19,
    .a = 0xff,
};

pub const Enemy = struct {
    entity: Entity,

    pub fn init(box: utils.Rectangle) Enemy {
        return Enemy{
            .entity = Entity.defaultEnemy(box),
        };
    }
};
