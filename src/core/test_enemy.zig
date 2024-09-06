const std = @import("std");
const timestamp = std.time.milliTimestamp;
const expect = std.testing.expect;

const Allocator = std.heap.page_allocator;

const utils = @import("../utils/utils.zig");

const enemyImport = @import("enemy.zig");
const Enemy = enemyImport.Enemy;
const EnemySpawner = enemyImport.EnemySpawner;

const entityImport = @import("entity.zig");
const Entity = entityImport.Entity;

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
    const oldAttackTime = spawner.delay.timer;

    const e = try spawner.spawn();
    defer if (e) |enemy| Allocator.destroy(enemy);
    try expect(e != null);

    try expect(spawner.delay.timer > oldAttackTime);
}

test "Should attack another entity" {
    const baseBox = utils.Rectangle{
        .x = 42,
        .y = 42,
        .w = 42,
        .h = 42,
    };

    const enemy = try Enemy.init(baseBox);
    defer Allocator.destroy(enemy);
    defer enemy.deinit();

    var entity = Entity{
        .cost = 0,
        .status = .{
            .range = 0,
            .attack = 0,
            .health = 1000,
        },
        .defaultStatus = .{
            .range = 0,
            .attack = 0,
            .health = 1000,
        },
    };

    const oldHp = entity.status.health;
    enemy.attackEntity(&entity);

    try expect(entity.status.health < oldHp);
}

test "Should validate attack cooldown and enemy range" {
    const baseBox = utils.Rectangle{
        .x = 42,
        .y = 42,
        .w = 42,
        .h = 42,
    };
    const enemyCenter = baseBox.getCenter();

    const enemy = try Enemy.init(baseBox);
    defer Allocator.destroy(enemy);
    defer enemy.deinit();

    enemy.entity.status.range = 10;
    var p1 = enemyCenter;
    p1.x += 10;
    p1.y += 10;

    // Should not attack if the enemy is far and attack is on cooldown
    try expect(!enemy.shouldAttack(p1));

    enemy.attackDelay.timer = timestamp();
    // Should not attack if the enemy is far and attack isnt on cooldown
    try expect(!enemy.shouldAttack(p1));

    var p2 = enemyCenter;
    p2.x += 3;
    p2.y += 3;
    enemy.attackDelay.timer = timestamp() + 3600;
    // Should not attack if the enemy near and attack is on cooldown
    try expect(!enemy.shouldAttack(p2));

    enemy.attackDelay.timer = timestamp();
    // Should attack if the enemy near and attack is on cooldown
    try expect(enemy.shouldAttack(p2));
}
