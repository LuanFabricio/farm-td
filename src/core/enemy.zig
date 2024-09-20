const std = @import("std");

const timestamp = std.time.timestamp;

const ArrayList = std.ArrayList;
const Allocator = std.heap.page_allocator;

const utils = @import("../utils/utils.zig");
const Delay = @import("../utils/delay.zig").Delay;

const Entity = @import("entity.zig").Entity;
const Turret = @import("turret.zig").Turret;

const gridImport = @import("grid.zig");
const Grid = gridImport.Grid;
const GridItemEnum = gridImport.GridItemEnum;

pub const DEFAULT_SPEED: f32 = 55;

pub const DEFAULT_COLOR = utils.Color{
    .r = 0x19,
    .g = 0xff,
    .b = 0x19,
    .a = 0xff,
};

pub const Enemy = struct {
    const This = @This();
    entity: Entity,
    box: utils.Rectangle,
    turrets: ArrayList(*Turret),
    attackDelay: Delay,

    pub fn init(box: utils.Rectangle) !*This {
        var enemyPtr = try Allocator.create(This);

        enemyPtr.box.copy(box);
        enemyPtr.entity = Entity.defaultEnemy();
        enemyPtr.turrets = ArrayList(*Turret).init(Allocator);

        enemyPtr.attackDelay = Delay.new(500, false);

        return enemyPtr;
    }

    pub fn deinit(self: *This) void {
        self.turrets.deinit();
    }

    pub fn copy(self: *This, other: This) void {
        self.box.copy(other.box);
        self.entity.copy(other.entity);
        self.turrets = ArrayList(*Turret).init(Allocator);
    }

    pub fn addObserver(self: *This, observer: *Turret) !void {
        std.debug.print("Turrets: {d}\n", .{self.turrets.items.len});
        try self.turrets.append(observer);
    }

    pub fn move(self: *This, frameTime: f32) void {
        if (self.entity.status.health > 0) {
            self.box.x += DEFAULT_SPEED * frameTime;
        }
    }

    pub fn shouldAttack(self: *const This, otherPosition: utils.Point) bool {
        return self.canAttack() and self.otherOnRange(otherPosition);
    }

    pub fn otherOnRange(self: *const This, otherPos: utils.Point) bool {
        const enemyPos = self.box.getCenter();
        const dist = enemyPos.calcDist(&otherPos);
        return dist <= self.entity.status.range;
    }

    pub fn canAttack(self: *const This) bool {
        return !self.attackDelay.onCooldown();
    }

    pub fn attackEntity(self: *This, entity: *Entity) void {
        entity.status.health -= self.entity.status.attack;
    }

    pub fn resetDelay(self: *This) void {
        self.attackDelay.applyDelay();
    }
};

pub const EnemySpawner = struct {
    delay: Delay,
    // delay: i64,
    // spawnTime: i64,
    baseBox: utils.Rectangle,

    pub fn new(delay: i64, baseBox: utils.Rectangle) EnemySpawner {
        return EnemySpawner{
            .delay = Delay.new(delay, false),
            .baseBox = baseBox,
        };
    }

    pub fn spawn(self: *EnemySpawner) !?*Enemy {
        if (self.delay.onCooldown()) return null;

        self.delay.applyDelay();
        return try Enemy.init(self.baseBox);
    }
};
