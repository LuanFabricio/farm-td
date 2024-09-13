const std = @import("std");
const Allocator = std.heap.page_allocator;

const timestamp = std.time.timestamp;

const utils = @import("../utils/utils.zig");
const Delay = @import("../utils/delay.zig").Delay;

const HitBox = @import("collision/hitbox.zig").HitBox;
const Projectile = @import("projectile.zig").Projectile;
const Enemy = @import("enemy.zig").Enemy;
const Entity = @import("entity.zig").Entity;

pub const TURRET_SIZE = utils.Point{
    .x = 32,
    .y = 64,
};

pub const DEFAULT_COLOR = utils.Color{
    .r = 0x99,
    .g = 0x99,
    .b = 0x99,
    .a = 0xff,
};

pub const Turret = struct {
    const This = @This();
    entity: Entity,
    delay: Delay,

    // Create on the stack
    pub fn new() This {
        return This{
            .entity = Entity.defaultTurret(),
            .delay = Delay.new(750, false),
        };
    }

    // Allocate on the heap
    pub fn init() !*This {
        var turretPtr = try Allocator.create(This);

        turretPtr.entity = Entity.defaultTurret();
        turretPtr.delay = Delay.new(750, false);

        return turretPtr;
    }

    pub fn copy(self: *This, other: This) void {
        self.entity.copy(other.entity);
        self.delay = other.delay;
    }

    pub fn shouldAttack(self: *const This, turretPosition: utils.Point, otherPosition: utils.Point) bool {
        return self.otherOnRange(turretPosition, otherPosition) and self.canAttack();
    }

    fn otherOnRange(self: *const This, turretPos: utils.Point, otherPos: utils.Point) bool {
        const dist = turretPos.calcDist(&otherPos);
        return dist <= self.entity.status.range;
    }
    fn canAttack(self: *const This) bool {
        return !self.delay.onCooldown();
    }

    pub fn attackEntity(self: *const This, otherEntity: *Entity) void {
        otherEntity.status.health -= self.entity.status.attack;
    }

    pub fn shoot(self: *const This, rect: utils.Rectangle, target: *Enemy) Projectile {
        return Projectile.new(
            HitBox.new(rect),
            target,
            self.entity.status.attack,
            -75.0,
        );
    }

    pub fn resetDelay(self: *This) void {
        self.delay.applyDelay();
    }
};
