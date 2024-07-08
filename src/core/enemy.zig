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
    entity: Entity,
    box: utils.Rectangle,
    turrets: ArrayList(*Turret),

    pub fn init(box: utils.Rectangle) !*Enemy {
        var enemyPtr = try Allocator.create(Enemy);

        enemyPtr.box.copy(box);
        enemyPtr.entity = Entity.defaultEnemy();
        enemyPtr.turrets = ArrayList(*Turret).init(Allocator);

        return enemyPtr;
    }

    pub fn deinit(self: *Enemy) void {
        self.turrets.deinit();
    }

    pub fn copy(self: *Enemy, other: Enemy) void {
        self.box.copy(other.box);
        self.entity.copy(other.entity);
        self.turrets = ArrayList(*Turret).init(Allocator);
    }

    pub fn addObserver(self: *Enemy, observer: *Turret) !void {
        std.debug.print("Turrets: {d}\n", .{self.turrets.items.len});
        try self.turrets.append(observer);
    }

    pub fn notifyAll(self: *Enemy) void {
        for (self.turrets.items) |turret| {
            turret.observer(&self.entity);
        }
    }

    pub fn move(self: *Enemy, frameTime: f32) void {
        if (self.entity.status.health > 0) {
            self.box.x += DEFAULT_SPEED * frameTime;
            self.notifyAll();
        }
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
