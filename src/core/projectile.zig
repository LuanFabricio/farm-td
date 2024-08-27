const std = @import("std");
const Pi = std.math.pi;

const utils = @import("../utils/utils.zig");
const HitBox = @import("../collision/hitbox.zig").HitBox;
const Enemy = @import("./enemy.zig").Enemy;

pub const PROJECTILE_DEFAULT_COLOR = utils.Color{
    .r = 0xff,
    .g = 0x22,
    .b = 0x22,
    .a = 0xff,
};

pub const Projectile = struct {
    const This = @This();
    hitbox: HitBox,
    target: *Enemy,
    damage: i32,
    speed: f32,

    pub fn new(hitbox: HitBox, target: *Enemy, damage: i32, speed: f32) This {
        return This{
            .hitbox = hitbox,
            .target = target,
            .speed = speed,
            .damage = damage,
        };
    }

    pub fn applyDamage(self: *This) void {
        self.target.entity.status.health -= self.damage;
    }

    pub fn updateAngle(self: *This) void {
        const dx = self.hitbox.hitbox.x - self.target.box.x;
        const dy = self.hitbox.hitbox.y - self.target.box.y;
        self.hitbox.angle = std.math.atan2(dy, dx) * 180.0 / Pi;
    }

    pub fn move(self: *This, frameTime: f32) void {
        const speedVec = self.getSpeedVec();
        self.hitbox.hitbox.x += speedVec.x * frameTime;
        self.hitbox.hitbox.y += speedVec.y * frameTime;
    }

    pub fn shouldDestroy(self: *const This, enemies: []*Enemy) bool {
        const projHitbox = self.hitbox;
        // const projSpeedVec = self.getSpeedVec();
        for (enemies) |enemy| {
            const enemyCollisionBox = HitBox.new(enemy.box);
            if (projHitbox.checkCollision(&enemyCollisionBox)) return true;
            // TODO: Go back to step collision
            // if (projHitbox.stepCollision(&enemyCollisionBox, projSpeedVec)) return true;
        }
        return false;
    }

    fn getSpeedVec(self: *const This) utils.Point {
        const angle = self.hitbox.angle * Pi / 180.0;
        return utils.Point{
            .x = self.speed * @cos(angle),
            .y = self.speed * @sin(angle),
        };
    }
};
