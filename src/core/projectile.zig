const std = @import("std");
const timestamp = std.time.milliTimestamp;
const Pi = std.math.pi;

const utils = @import("../utils/utils.zig");
const HitBox = @import("collision/hitbox.zig").HitBox;
const Enemy = @import("enemy.zig").Enemy;
const Entity = @import("entity.zig").Entity;

pub const PROJECTILE_FILETIME_MS: i64 = 30 * 1000;

pub const PROJECTILE_DEFAULT_COLOR = utils.Color{
    .r = 0xff,
    .g = 0x22,
    .b = 0x22,
    .a = 0xff,
};

pub const ShootType = enum {
    follow,
    spam,
};

pub const ShootTarget = union(ShootType) {
    follow: *Enemy,
    spam: void,
};

pub const Projectile = struct {
    const This = @This();
    hitbox: HitBox,
    damage: i32,
    speed: f32,
    shootTarget: ShootTarget,
    expirationTime: i64,

    pub fn new(hitbox: HitBox, shootTarget: ShootTarget, damage: i32, speed: f32) This {
        return This{
            .hitbox = hitbox,
            .shootTarget = shootTarget,
            .speed = speed,
            .damage = damage,
            .expirationTime = timestamp() + PROJECTILE_FILETIME_MS,
        };
    }

    pub fn applyDamage(self: *This, target: *Entity) void {
        target.status.health -= self.damage;
    }

    pub fn updateAngle(self: *This) void {
        if (self.shootTarget == .follow) {
            const target = self.shootTarget.follow;
            const dx = self.hitbox.hitbox.x - target.box.x;
            const dy = self.hitbox.hitbox.y - target.box.y;
            self.hitbox.angle = std.math.atan2(dy, dx) * 180.0 / Pi;
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
