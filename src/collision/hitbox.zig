const std = @import("std");

const utils = @import("../utils/utils.zig");

pub const HitBox = struct {
    const This = @This();

    hitbox: utils.Rectangle,

    pub fn new(hitbox: utils.Rectangle) This {
        return This{
            .hitbox = hitbox,
        };
    }

    pub fn stepCollision(self: *const This, target: *const This, speed: utils.Point) bool {
        if (!self.canCollide(target, speed)) return false;

        const baseRect: utils.Rectangle = self.hitbox;

        var baseHb = This.new(baseRect);
        var hb = This.new(baseRect);
        const step: f32 = 0.1;
        for (0..12) |_| {
            hb.hitbox.x = baseHb.hitbox.x + speed.x * step;
            hb.hitbox.y = baseHb.hitbox.y;

            if (hb.checkCollision(target)) return true;

            hb.hitbox.x = baseHb.hitbox.x;
            hb.hitbox.y = baseHb.hitbox.y + speed.y * step;
            if (hb.checkCollision(target)) return true;

            baseHb.hitbox.x += speed.x * step;
            baseHb.hitbox.y += speed.y * step;
        }

        return false;
    }

    pub fn checkCollision(self: *const This, target: *const This) bool {
        return self.hitbox.x + self.hitbox.w >= target.hitbox.x and self.hitbox.x <= target.hitbox.x + target.hitbox.x and self.hitbox.y + self.hitbox.h >= target.hitbox.y and self.hitbox.y <= target.hitbox.y + target.hitbox.h;
    }

    pub fn canCollide(self: *const This, target: *const This, speed: utils.Point) bool {
        const dx = target.hitbox.x - self.hitbox.x;
        const dy = target.hitbox.y - self.hitbox.y;

        const dxSignal = @as(u32, @bitCast(dx)) & 0x80000000;
        const speedXSignal = @as(u32, @bitCast(speed.x)) & 0x80000000;
        const xSampleSignal = dxSignal == speedXSignal;

        const dySignal = @as(u32, @bitCast(dy)) & 0x80000000;
        const speedYSignal = @as(u32, @bitCast(speed.y)) & 0x80000000;
        const ySampleSignal = dySignal == speedYSignal;

        return xSampleSignal and ySampleSignal;
    }
};
