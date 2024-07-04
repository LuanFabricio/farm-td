const std = @import("std");

const ArrayList = std.ArrayList;
const Allocator = std.heap.page_allocator;

const utils = @import("../utils/utils.zig");

const Entity = @import("entity.zig").Entity;
const Turret = @import("turret.zig").Turret;

const DEFAULT_SPEED: f32 = 10;

pub const DEFAULT_COLOR = utils.Color{
    .r = 0x19,
    .g = 0xff,
    .b = 0x19,
    .a = 0xff,
};

pub const Enemy = struct {
    entity: Entity,
    turrets: ArrayList(*Turret),

    pub fn init(box: utils.Rectangle) !*Enemy {
        var enemyPtr = try Allocator.create(Enemy);

        enemyPtr.entity = Entity.defaultEnemy(box);
        enemyPtr.turrets = ArrayList(*Turret).init(Allocator);

        return enemyPtr;
    }

    pub fn deinit(self: *Enemy) void {
        self.turrets.deinit();
    }

    pub fn copy(self: *Enemy, other: Enemy) void {
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
            self.entity.box.x += DEFAULT_SPEED * frameTime;
            self.notifyAll();
        }
    }
};
