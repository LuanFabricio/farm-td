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

pub const TurretGrid = Grid(Turret);
pub const FarmGrid = Grid(Farm);

pub const Game = struct {
    const This = @This();

    enemies: ArrayList(*Enemy),
    enemySpawners: ArrayList(EnemySpawner),
    turretGrid: TurretGrid,
    farmGrid: FarmGrid,
    gold: u32,

    pub fn init(width: usize, height: usize) !This {
        return This{
            .enemies = ArrayList(*Enemy).init(Allocator),
            .enemySpawners = ArrayList(EnemySpawner).init(Allocator),
            .turretGrid = try TurretGrid.init(width, height),
            .farmGrid = try FarmGrid.init(width, height),
            .gold = 0,
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
    }

    pub fn addEnemySpawn(self: *This, enemySpawn: EnemySpawner) !void {
        try self.enemySpawners.append(enemySpawn);
    }

    pub fn addEnemy(self: *This, enemy: *Enemy) !void {
        try self.enemies.append(enemy);
    }

    pub fn addTurret(self: *This, x: usize, y: usize, turret: *Turret) !void {
        self.turretGrid.addItem(x, y, turret);
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
                try self.enemies.append(enemyPtr);
            }
        }
    }

    pub fn turretShoot(self: *This, offset: utils.Point, gridSize: f32) !void {
        for (self.turretGrid.items.items, 0..) |turretOption, idx| {
            if (turretOption) |turret| {
                var turretPosition = self.turretGrid.indexToXY(idx);
                turretPosition.x = turretPosition.x * gridSize + offset.x;
                turretPosition.y = turretPosition.y * gridSize + offset.y;

                for (self.enemies.items) |enemy| {
                    if (enemy.entity.status.health <= 0) continue;
                    const enemyCenter = enemy.box.getCenter();

                    // TODO: Maybe move to nearest enemy approach
                    if (turret.shouldAttack(turretPosition, enemyCenter)) {
                        turret.attackEntity(&enemy.entity);
                        turret.resetDelay();
                        break;
                    }
                }
            }
        }
    }

    pub fn cleanDeadEnemies(self: *This) void {
        var i: usize = 0;
        while (i < self.enemies.items.len) : (i += 1) {
            if (self.enemies.items[i].entity.status.health <= 0) {
                const enemyPtr = self.enemies.swapRemove(i);

                Allocator.destroy(enemyPtr);
                if (i > 0) i -= 1;
            }
        }
    }
};
