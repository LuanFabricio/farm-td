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
            const copyHeap = try Turret.init();
            copyHeap.copy(cursorTurret.*);
            self.turretGrid.addItem(x, y, copyHeap);

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

    pub fn cleanDeadEnemies(self: *This, maxWidth: f32) void {
        var i: usize = 0;
        while (i < self.enemies.items.len) : (i += 1) {
            const enemy = self.enemies.items[i];
            const enemyHp = enemy.entity.status.health;
            const enemyLeft = enemy.box.x;
            if (enemyHp <= 0 or enemyLeft > maxWidth) {
                const enemyPtr = self.enemies.swapRemove(i);

                Allocator.destroy(enemyPtr);
                if (i > 0) i -= 1;
            }
        }
    }

    pub fn enemyAttack(self: *This, turretOffset: utils.Point, gridSize: f32) !void {
        for (self.enemies.items) |enemy| {
            for (self.turretGrid.items.items, 0..) |turretOption, idx| {
                if (turretOption == null) continue;

                var turretPosition = self.turretGrid.indexToXY(idx);
                turretPosition.x = turretPosition.x * gridSize + turretOffset.x;
                turretPosition.y = turretPosition.y * gridSize + turretOffset.y;
                turretPosition.x += turretImport.TURRET_SIZE.x;
                turretPosition.y += turretImport.TURRET_SIZE.y;

                if (enemy.shouldAttack(turretPosition)) {
                    const turret = turretOption.?;
                    enemy.attackEntity(&turret.entity);
                    enemy.resetDelay();
                    break;
                }
            }
        }
    }

    pub fn cleanDeadTurrets(self: *This) void {
        for (0..self.turretGrid.items.items.len) |idx| {
            if (self.turretGrid.items.items[idx]) |turret| {
                if (turret.entity.status.health <= 0) self.turretGrid.items.items[idx] = null;
            }
        }
    }
};
