const std = @import("std");
const expect = std.testing.expect;

const Allocator = std.heap.page_allocator;

const utils = @import("../utils/utils.zig");

const enemyImport = @import("enemy.zig");
const Enemy = enemyImport.Enemy;
const EnemySpawner = enemyImport.EnemySpawner;

fn compareEnemies(e1: Enemy, e2: Enemy) !void {
    try expect(e1.entity.status.isEqual(e2.entity.status));
    try expect(e1.entity.defaultStatus.isEqual(e2.entity.defaultStatus));

    try expect(e1.box.x == e2.box.x);
    try expect(e1.box.y == e2.box.y);
    try expect(e1.box.w == e2.box.w);
    try expect(e1.box.h == e2.box.h);
}

test "Should copy another enemy" {
    const box = utils.Rectangle{
        .x = 42,
        .y = 42,
        .w = 42,
        .h = 42,
    };

    const e1 = try Enemy.init(box);
    defer e1.deinit();

    var e2: Enemy = undefined;
    e2.copy(e1.*);

    try compareEnemies(e1.*, e2);
}

test "Should spawn an enemy and update the spawnTime" {
    const baseBox = utils.Rectangle{
        .x = 42,
        .y = 42,
        .w = 42,
        .h = 42,
    };
    var spawner = EnemySpawner.new(15, baseBox);
    const oldAttackTime = spawner.spawnTime;

    const e = try spawner.spawn();
    defer if (e) |enemy| Allocator.destroy(enemy);
    try expect(e != null);

    try expect(spawner.spawnTime > oldAttackTime);
}
