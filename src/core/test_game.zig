const std = @import("std");
const expect = std.testing.expect;

const utils = @import("../utils/utils.zig");

const enemyImport = @import("enemy.zig");
const EnemySpawner = enemyImport.EnemySpawner;

const gameImport = @import("game.zig");
const Game = gameImport.Game;

test "It should add a enemy spawner" {
    const baseBox = utils.Rectangle{ .x = 0, .y = 0, .w = 32, .h = 32 };
    const newSpawner = EnemySpawner.new(10, baseBox);

    var game = try Game.init(0, 32, 32, 32, 32, 32, 32);
    try expect(game.enemySpawners.items.len == 0);

    try game.addEnemySpawn(newSpawner);
    try expect(game.enemySpawners.items.len == 1);

    // Comparing enemy spawners
    const gameSpawner = game.enemySpawners.items[0];

    try expect(newSpawner.delay == gameSpawner.delay);
    try expect(newSpawner.spawnTime == gameSpawner.spawnTime);
    try expect(newSpawner.baseBox.x == gameSpawner.baseBox.x);
    try expect(newSpawner.baseBox.y == gameSpawner.baseBox.y);
    try expect(newSpawner.baseBox.w == gameSpawner.baseBox.w);
    try expect(newSpawner.baseBox.h == gameSpawner.baseBox.h);
}
