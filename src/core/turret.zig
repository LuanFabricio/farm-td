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
    pub fn new() Turret {
        const attackTime = timestamp();

        return Turret{
            .entity = Entity.defaultTurret(),
            .attackDelay = 1,
            .attackTime = attackTime,
        };
    }

    // Allocate on the heap
    pub fn init() !*Turret {
        var turretPtr = try Allocator.create(Turret);
        const attackTime = timestamp();

        turretPtr.entity = Entity.defaultTurret();
        turretPtr.attackDelay = 1;
        turretPtr.attackTime = attackTime;

        return turretPtr;
    }

    pub fn copy(self: *Turret, other: Turret) void {
        self.entity.copy(other.entity);
        self.attackTime = other.attackTime;
        self.attackDelay = other.attackDelay;
    }

    pub fn shouldAttack(self: *const Turret, turretPosition: utils.Point, otherPosition: utils.Point) bool {
        return self.otherOnRange(turretPosition, otherPosition) and self.canAttack();
    }

    fn otherOnRange(self: *const Turret, turretPos: utils.Point, otherPos: utils.Point) bool {
        const dist = turretPos.calcDist(&otherPos);
        return dist <= self.entity.status.range;
    }

    fn canAttack(self: *const Turret) bool {
        const now = timestamp();
        return now >= self.attackTime;
    }

    pub fn attackEntity(self: *const Turret, otherEntity: *Entity) void {
        otherEntity.status.health -= self.entity.status.attack;
    }

    pub fn resetDelay(self: *Turret) void {
        const now = timestamp();
        self.attackTime = now + self.attackDelay;
    }

    pub fn observer(_: *Turret, _: *Entity) void {
        // const enemyCenter = entity.box.getCenter();
        // const selfCenter = self.entity.box.getCenter();
        // const dist = selfCenter.calcDist(&enemyCenter);

        // const range = self.entity.status.range;

        // // NOTE: Maybe, in the future, create two types of turrets radius and line turrets.
        // // Where the radius turret shots based on the radius range (a circle)
        // // and the line turrets shot based on the line in the grid
        // if (dist <= range) {
        //     const now = timestamp();
        //     if (now >= self.attackTime) {
        //         entity.status.health -= self.entity.status.attack;
        //         self.attackTime = now + self.attackDelay;
        //     }
        // }
    }
};
