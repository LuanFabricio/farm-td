const std = @import("std");
const Allocator = std.heap.page_allocator;

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

    // Create on the stack
    pub fn new(box: utils.Rectangle) Turret {
        const attackTime = timestamp();

        return Turret{
            .entity = Entity.defaultTurret(box),
            .attackDelay = 1,
            .attackTime = attackTime,
        };
    }

    // Allocate on the heap
    pub fn init(box: utils.Rectangle) !*Turret {
        var turretPtr = try Allocator.create(Turret);
        const attackTime = timestamp();

        turretPtr.entity = Entity.defaultTurret(box);
        turretPtr.attackDelay = 1;
        turretPtr.attackTime = attackTime;

        return turretPtr;
    }

    pub fn copy(self: *Turret, other: Turret) void {
        self.entity.copy(other.entity);
        self.attackTime = other.attackTime;
        self.attackDelay = other.attackDelay;
    }

    pub fn observer(self: *Turret, entity: *Entity) void {
        const enemyCenter = entity.box.getCenter();
        const selfCenter = self.entity.box.getCenter();
        const dist = selfCenter.calcDist(&enemyCenter);

        const range = self.entity.status.range;

        // NOTE: Maybe, in the future, create two types of turrets radius and line turrets.
        // Where the radius turret shots based on the radius range (a circle)
        // and the line turrets shot based on the line in the grid
        if (dist <= range) {
            const now = timestamp();
            if (now >= self.attackTime) {
                entity.status.health -= self.entity.status.attack;
                self.attackTime = now + self.attackDelay;
            }
        }
    }
};
