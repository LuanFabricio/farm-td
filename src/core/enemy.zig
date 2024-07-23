const std = @import("std");

const timestamp = std.time.timestamp;

const ArrayList = std.ArrayList;
const Allocator = std.heap.page_allocator;

const utils = @import("../utils/utils.zig");

const Entity = @import("entity.zig").Entity;
const Turret = @import("turret.zig").Turret;

const gridImport = @import("grid.zig");
const Grid = gridImport.Grid;
const GridItemEnum = gridImport.GridItemEnum;

const DEFAULT_SPEED: f32 = 10;

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
    // TODO: create an attack module
    attackDelay: i64,
    attackTime: i64,

    pub fn init(box: utils.Rectangle) !*This {
        var enemyPtr = try Allocator.create(This);

        enemyPtr.box.copy(box);
        enemyPtr.entity = Entity.defaultEnemy();
        enemyPtr.turrets = ArrayList(*Turret).init(Allocator);

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

    pub fn notifyAll(self: *This) void {
        for (self.turrets.items) |turret| {
            turret.observer(&self.entity);
        }
    }

    pub fn move(self: *This, frameTime: f32) void {
        if (self.entity.status.health > 0) {
            self.box.x += DEFAULT_SPEED * frameTime;
            self.notifyAll();
        }
    }

    pub fn shouldAttack(self: *const This, otherPosition: utils.Point) bool {
        return self.canAttack() and self.otherOnRange(otherPosition);
    }

    fn otherOnRange(self: *const This, otherPos: utils.Point) bool {
        const enemyPos = self.box.getCenter();
        const dist = enemyPos.calcDist(&otherPos);
        return dist <= self.entity.status.range;
    }

    fn canAttack(self: *const This) bool {
        const now = timestamp();
        return now >= self.attackTime;
    }

    pub fn attackEntity(self: *This, entity: *Entity) void {
        entity.status.health -= self.entity.status.attack;
    }

    pub fn resetDelay(self: *This) void {
        const now = timestamp();
        self.attackTime = now + self.attackDelay;
    }
};

pub const EnemySpawner = struct {
    delay: i64,
    spawnTime: i64,
    baseBox: utils.Rectangle,

    pub fn new(delay: i64, baseBox: utils.Rectangle) EnemySpawner {
        return EnemySpawner{
            .delay = delay,
            .spawnTime = timestamp(),
            .baseBox = baseBox,
        };
    }

    pub fn spawn(self: *EnemySpawner) !?*Enemy {
        const now = timestamp();
        if (self.spawnTime > now) {
            return null;
        }
        self.spawnTime = now + self.delay;

        return try Enemy.init(self.baseBox);
    }
};
