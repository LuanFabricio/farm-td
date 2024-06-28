const std = @import("std");

const ArrayList = std.ArrayList;
const PageAllocator = std.heap.page_allocator;

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

    pub fn init(box: utils.Rectangle) Enemy {
        return Enemy{
            .entity = Entity.defaultEnemy(box),
            .turrets = ArrayList(*Turret).init(PageAllocator),
        };
    }

    pub fn deinit(self: *Enemy) void {
        self.turrets.deinit();
    }

    pub fn addObserver(self: *Enemy, observer: *Turret) !void {
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
