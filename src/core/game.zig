const std = @import("std");
const Allocator = std.heap.page_allocator;
const ArrayList = std.ArrayList;

const turretImport = @import("turret.zig");
const Turret = turretImport.Turret;
const enemyImport = @import("enemy.zig");
const Enemy = enemyImport.Enemy;
const gridImport = @import("grid.zig");
const Grid = gridImport.Grid;

pub const Game = struct {
    enemies: ArrayList(*Enemy),
    grid: Grid,

    pub fn init(width: usize, height: usize) !Game {
        return Game{
            .enemies = ArrayList(*Enemy).init(Allocator),
            .grid = try Grid.init(width, height),
        };
    }

    pub fn deinit(self: *Game) void {
        self.enemies.deinit();
        self.grid.deinit();
    }

    pub fn addEnemy(self: *Game, enemy: *Enemy) !void {
        try self.enemies.append(enemy);
    }

    pub fn addTurret(self: *Game, x: usize, y: usize, turret: *Turret) !void {
        self.grid.addItem(x, y, turret);
    }
};
