const std = @import("std");

const timestamp = std.time.timestamp;
const Allocator = std.heap.page_allocator;
const ArrayList = std.ArrayList;

const utils = @import("../utils/utils.zig");

const turretImport = @import("turret.zig");
const Turret = turretImport.Turret;

const enemyImport = @import("enemy.zig");
const Enemy = enemyImport.Enemy;
const EnemySpawner = enemyImport.EnemySpawner;

const gridImport = @import("grid.zig");
const Grid = gridImport.Grid;

const farmImport = @import("farm.zig");
const Farm = farmImport.Farm;

const projectileImport = @import("projectile.zig");
const Projectile = projectileImport.Projectile;
const ShootType = projectileImport.ShootType;

const HitBox = @import("collision/hitbox.zig").HitBox;

pub const TurretGrid = Grid(Turret);
pub const FarmGrid = Grid(Farm);

pub const Game = struct {
    const This = @This();

    enemies: ArrayList(*Enemy),
    enemySpawners: ArrayList(EnemySpawner),
    projectiles: ArrayList(Projectile),
    turretGrid: TurretGrid,
    turretBuyGrid: TurretGrid,
    farmGrid: FarmGrid,
    farmBuyGrid: FarmGrid,
    gold: u32,
    cursorFarm: ?*Farm,
    cursorTurret: ?*Turret,

    pub fn init(
        initial_gold: u32,
        widthTurret: usize,
        heightTurret: usize,
        widthFarm: usize,
        heightFarm: usize,
        widthBuy: usize,
        heightBuy: usize,
    ) !This {
        return This{
            .enemies = ArrayList(*Enemy).init(Allocator),
            .enemySpawners = ArrayList(EnemySpawner).init(Allocator),
            .projectiles = ArrayList(Projectile).init(Allocator),
            .turretGrid = try TurretGrid.init(widthTurret, heightTurret),
            .turretBuyGrid = try TurretGrid.init(widthBuy, heightBuy),
            .farmGrid = try FarmGrid.init(widthFarm, heightFarm),
            .farmBuyGrid = try FarmGrid.init(widthBuy, heightBuy),
            .gold = initial_gold,
            .cursorFarm = null,
            .cursorTurret = null,
        };
    }

    pub fn deinit(self: *This) void {
        for (self.enemies.items) |enemyPtr| {
            Allocator.destroy(enemyPtr);
        }
        self.enemies.deinit();
        self.enemySpawners.deinit();
        self.farmGrid.deinit();
        self.turretGrid.deinit();
        self.projectiles.deinit();

        if (self.cursorFarm) |cursorFarm| {
            Allocator.destroy(cursorFarm);
        }
    }

    pub fn addEnemySpawn(self: *This, enemySpawn: EnemySpawner) !void {
        try self.enemySpawners.append(enemySpawn);
    }

    pub fn addEnemy(self: *This, enemy: *Enemy) !void {
        try self.enemies.append(enemy);
    }

    pub fn addTurret(self: *This, x: usize, y: usize) !bool {
        if (self.cursorTurret) |cursorTurret| {
            if (self.gold < cursorTurret.entity.cost) return false;

            const copyHeap = try Turret.init();
            copyHeap.copy(cursorTurret.*);
            self.turretGrid.addItem(x, y, copyHeap);

            self.gold -= cursorTurret.entity.cost;
            self.cursorTurret = null;
            return true;
        }
        return false;
    }

    pub fn addFarm(self: *This, x: usize, y: usize) !bool {
        if (self.cursorFarm) |cursorFarm| {
            if (self.gold >= cursorFarm.cost) {
                self.gold -= cursorFarm.cost;
                self.farmGrid.addItem(x, y, try cursorFarm.heap_clone());

                self.cursorFarm = null;
                return true;
            }
        }
        return false;
    }

    pub fn updateCursorFarm(self: *This, x: usize, y: usize) void {
        self.cursorFarm = self.farmBuyGrid.getItem(x, y) catch null;
    }

    pub fn updateCursorTurret(self: *This, x: usize, y: usize) void {
        self.cursorTurret = self.turretBuyGrid.getItem(x, y) catch null;
    }

    pub fn farmGold(self: *This) void {
        for (self.farmGrid.getItems()) |farm| {
            if (farm == null) continue;

            if (farm.?.getGold()) |g| self.gold += g;
        }
    }

    pub fn spawnEnemies(self: *This) !void {
        for (self.enemySpawners.items) |*enemy| {
            const enempyOption = try enemy.spawn();
            if (enempyOption) |enemyPtr| {
                enemyPtr.entity.status.range = enemyPtr.box.w / 2;
                try self.enemies.append(enemyPtr);
            }
        }
    }

    pub fn turretShoot(self: *This, offset: utils.Point, gridSize: f32) !void {
        for (self.turretGrid.items.items, 0..) |turretOption, idx| {
            if (turretOption) |turret| {
                const turretPosition = self.turretGrid.indexToXY(idx);
                const turretRect = utils.Rectangle{
                    .x = turretPosition.x * gridSize + offset.x,
                    .y = turretPosition.y * gridSize + offset.y,
                    .w = turretImport.TURRET_SIZE.x,
                    .h = turretImport.TURRET_SIZE.y,
                };
                const turretCenter = turretRect.getCenter();

                var nearestEnemy: ?*Enemy = null;
                for (self.enemies.items) |enemy| {
                    if (enemy.entity.status.health <= 0) continue;
                    const enemyCenter = enemy.box.getCenter();

                    if (turret.shouldAttack(turretCenter, enemyCenter)) {
                        if (nearestEnemy) |currentEnemy| {
                            const currentDist = turretCenter.calcDist(&currentEnemy.box.getCenter());
                            const otherDist = turretCenter.calcDist(&enemy.box.getCenter());

                            if (currentDist > otherDist) {
                                nearestEnemy = enemy;
                            }
                        } else {
                            nearestEnemy = enemy;
                        }
                    }
                }
                if (nearestEnemy) |enemy| {
                    const projectileRect = utils.Rectangle{
                        .x = turretCenter.x,
                        .y = turretCenter.y,
                        .w = 8,
                        .h = 4,
                    };
                    const projectile = turret.shoot(projectileRect, enemy);
                    try self.projectiles.append(projectile);

                    turret.resetDelay();
                }
            }
        }
    }

    pub fn cleanDeadEnemies(self: *This, maxWidth: f32) void {
        var i: usize = 0;
        while (i < self.enemies.items.len) : (i += 1) {
            const enemy = self.enemies.items[i];
            const enemyHp = enemy.entity.status.health;
            const enemyLeft = enemy.box.x;
            if (enemyHp <= 0 or enemyLeft > maxWidth) {
                const enemyPtr = self.enemies.swapRemove(i);

                self.cleanOrphansProjectiles(enemyPtr);
                Allocator.destroy(enemyPtr);
                if (i > 0) i -= 1;
            }
        }
    }

    // TODO: Review this approach, maybe use some kind of HashMap
    // to get Projectiles by an Enemy pointer
    // or get an Enemy pointer by a Projectile
    fn cleanOrphansProjectiles(self: *This, enemyPtr: *Enemy) void {
        var i: usize = 0;
        while (i < self.projectiles.items.len) {
            switch (self.projectiles.items[i].shootType) {
                .follow => |target| {
                    if (target == enemyPtr) {
                        _ = self.projectiles.swapRemove(i);
                        continue;
                    }
                },
                else => {},
            }

            i += 1;
        }
    }

    pub fn enemyMoveOrAttack(self: *This, turretOffset: utils.Point, gridSize: f32, frametime: f32) !void {
        // TODO(luan): Improve speed by pre-processing turret hitbox
        // Maybe save in a cache
        for (self.enemies.items) |enemy| {
            var canMove = true;
            for (self.turretGrid.items.items, 0..) |turretOption, idx| {
                if (turretOption == null) continue;

                var turretPosition = self.turretGrid.indexToXY(idx);
                turretPosition.x = turretPosition.x * gridSize + turretOffset.x;
                turretPosition.y = turretPosition.y * gridSize + turretOffset.y;
                turretPosition.x += turretImport.TURRET_SIZE.x;
                turretPosition.y += turretImport.TURRET_SIZE.y;

                const enemyHitbox = HitBox.new(enemy.box);
                const turretRect = utils.Rectangle{
                    .x = turretPosition.x,
                    .y = turretPosition.y,
                    .w = turretImport.TURRET_SIZE.x,
                    .h = turretImport.TURRET_SIZE.y,
                };
                const turretHibox = HitBox.new(turretRect);

                if (enemyHitbox.checkCollision(&turretHibox)) {
                    canMove = false;
                    if (enemy.canAttack()) {
                        const turret = turretOption.?;
                        enemy.attackEntity(&turret.entity);
                        enemy.resetDelay();

                        std.debug.print("Hit ", .{});
                        break;
                    }
                }
            }

            // std.debug.print("Enemy: {any}\n", .{enemy.box});
            if (canMove) {
                enemy.move(frametime);
            }
        }
    }

    pub fn projectileRun(self: *This, frametime: f32) void {
        var i: usize = 0;
        while (i < self.projectiles.items.len) {
            var projectile = &self.projectiles.items[i];
            if (projectile.getEnemyHitted(self.enemies.items)) |enemy| {
                projectile.applyDamage(&enemy.entity);
                _ = self.projectiles.swapRemove(i);
                continue;
            }

            projectile.updateAngle();
            projectile.move(frametime);
            i += 1;
        }
    }

    fn projectileCollide(self: *This, projectile: *const Projectile, frametime: f32) bool {
        const projHitbox = projectile.hitbox;
        const projVecSpeed = utils.Point{ .x = projectile.speed * frametime, .y = 0 };
        for (self.enemies.items) |enemy| {
            const enemyCollisionBox = HitBox.new(enemy.box);
            if (projHitbox.stepCollision(&enemyCollisionBox, projVecSpeed)) return true;
        }

        return false;
    }

    pub fn cleanDeadTurrets(self: *This) void {
        for (0..self.turretGrid.items.items.len) |idx| {
            if (self.turretGrid.items.items[idx]) |turret| {
                if (turret.entity.status.health <= 0) self.turretGrid.items.items[idx] = null;
            }
        }
    }
};
