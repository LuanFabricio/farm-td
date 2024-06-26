const utils = @import("../utils/utils.zig");

const Entity = @import("entity.zig").Entity;

pub const DEFAULT_COLOR = utils.Color{
    .r = 0x99,
    .g = 0x99,
    .b = 0x99,
    .a = 0xff,
};

pub const Turret = struct {
    entity: Entity,

    pub fn new(box: utils.Rectangle) Turret {
        return Turret{
            .entity = Entity.defaultTurret(box),
        };
    }

    pub fn observer(self: *Turret, entity: *Entity) void {
        entity.status.health -= self.entity.status.attack;
    }
};
