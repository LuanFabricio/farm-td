const std = @import("std");

const timestamp = std.time.timestamp;

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
    attackDelay: i64,
    attackTime: i64,

    pub fn new(box: utils.Rectangle) Turret {
        const attackTime = timestamp();

        return Turret{
            .entity = Entity.defaultTurret(box),
            .attackDelay = 1,
            .attackTime = attackTime,
        };
    }

    pub fn observer(self: *Turret, entity: *Entity) void {
        const now = timestamp();
        if (now >= self.attackTime) {
            entity.status.health -= self.entity.status.attack;
            self.attackTime = now + self.attackDelay;
        }
    }
};
