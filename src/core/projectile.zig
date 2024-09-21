const std = @import("std");
const Pi = std.math.pi;

const utils = @import("../utils/utils.zig");
const HitBox = @import("collision/hitbox.zig").HitBox;
const Enemy = @import("enemy.zig").Enemy;
const Entity = @import("entity.zig").Entity;

pub const PROJECTILE_DEFAULT_COLOR = utils.Color{
    .r = 0xff,
    .g = 0x22,
    .b = 0x22,
    .a = 0xff,
};

pub const ShootType = union(enum) {
    follow: *Enemy,
    spam: void,
};

pub const Projectile = struct {
    const This = @This();
    hitbox: HitBox,
    damage: i32,
    speed: f32,
    shootType: ShootType,

    pub fn new(hitbox: HitBox, shootType: ShootType, damage: i32, speed: f32) This {
        return This{
            .hitbox = hitbox,
            .shootType = shootType,
            .speed = speed,
            .damage = damage,
        };
    }

    pub fn applyDamage(self: *This, target: *Entity) void {
        target.status.health -= self.damage;
    }

    pub fn updateAngle(self: *This) void {
        switch (self.shootType) {
            .follow => |target| {
                const dx = self.hitbox.hitbox.x - target.box.x;
                const dy = self.hitbox.hitbox.y - target.box.y;
                self.hitbox.angle = std.math.atan2(dy, dx) * 180.0 / Pi;
            },
            else => {},
        }
    }

    pub fn move(self: *This, frameTime: f32) void {
        const speedVec = self.getSpeedVec();
        self.hitbox.hitbox.x += speedVec.x * frameTime;
        self.hitbox.hitbox.y += speedVec.y * frameTime;
    }

    pub fn getEnemyHitted(self: *const This, enemies: []*Enemy) ?*Enemy {
        const projHitbox = self.hitbox;
        // const projSpeedVec = self.getSpeedVec();
        for (enemies) |enemy| {
            const enemyCollisionBox = HitBox.new(enemy.box);
            if (projHitbox.checkCollision(&enemyCollisionBox)) return enemy;
            // TODO: Go back to step collision
            // if (projHitbox.stepCollision(&enemyCollisionBox, projSpeedVec)) return true;
        }
        return null;
    }

    fn getSpeedVec(self: *const This) utils.Point {
        const angle = self.hitbox.angle * Pi / 180.0;
        return utils.Point{
            .x = self.speed * @cos(angle),
            .y = self.speed * @sin(angle),
        };
    }
};
