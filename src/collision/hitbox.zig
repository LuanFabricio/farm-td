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

        const baseHb = This.new(baseRect);
        var hb = This.new(baseRect);
        const stepSize = 12;
        const step: f32 = 1.0 / @as(f32, @floatFromInt(stepSize));
        for (1..stepSize + 1) |idx| {
            const currentSpeedStep = step * @as(f32, @floatFromInt(idx));
            const lastSpeedStep = step * @as(f32, @floatFromInt(idx - 1));

            hb.hitbox.x = baseHb.hitbox.x + speed.x * currentSpeedStep;
            hb.hitbox.y = baseHb.hitbox.y + speed.y * lastSpeedStep;
            if (hb.checkCollision(target)) return true;

            hb.hitbox.x = baseHb.hitbox.x + speed.x * lastSpeedStep;
            hb.hitbox.y = baseHb.hitbox.y + speed.y * currentSpeedStep;
            if (hb.checkCollision(target)) return true;

            hb.hitbox.y = baseHb.hitbox.y + speed.y * currentSpeedStep;
            hb.hitbox.x = baseHb.hitbox.x + speed.x * currentSpeedStep;
            if (hb.checkCollision(target)) return true;
        }

        return false;
    }

    pub fn checkCollision(self: *const This, target: *const This) bool {
        const rightLeft = self.hitbox.x + self.hitbox.w >= target.hitbox.x;
        const leftRight = self.hitbox.x <= target.hitbox.x + target.hitbox.x;
        const bottomUp = self.hitbox.y + self.hitbox.h >= target.hitbox.y;
        const upBottom = self.hitbox.y <= target.hitbox.y + target.hitbox.h;

        return rightLeft and leftRight and bottomUp and upBottom;
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
