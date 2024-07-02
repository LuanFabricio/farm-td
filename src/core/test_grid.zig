const std = @import("std");
const expect = std.testing.expect;

const utils = @import("../utils/utils.zig");
const Turret = @import("turret.zig").Turret;
const Enemy = @import("enemy.zig").Enemy;
const Entity = @import("entity.zig").Entity;

const grid = @import("grid.zig");
const Grid = grid.Grid;
const GridItem = grid.GridItem;
const GridItemEnum = grid.GridItemEnum;

fn compareEntities(e1: Entity, e2: Entity) !void {
    try expect(e1.box.x == e2.box.x);
    try expect(e1.box.y == e2.box.y);
    try expect(e1.box.w == e2.box.w);
    try expect(e1.box.h == e2.box.h);

    try expect(e1.status.health == e2.status.health);
    try expect(e1.status.attack == e2.status.attack);
    try expect(e1.status.range == e2.status.range);

    try expect(e1.defaultStatus.health == e2.defaultStatus.health);
    try expect(e1.defaultStatus.attack == e2.defaultStatus.attack);
    try expect(e1.defaultStatus.range == e2.defaultStatus.range);
}

test "It should create a new Grid" {
    const w = 32;
    const h = 32;
    const g = try Grid.init(w, h);
    defer g.deinit();

    const len = w * h;
    try expect(g.width == w);
    try expect(g.height == h);
    try expect(g.items.items.len == len);
}

test "It should add an item" {
    var g = try Grid.init(32, 32);
    defer g.deinit();

    var t = Turret.new(.{
        .x = 42,
        .y = 42,
        .w = 32,
        .h = 32,
    });
    try g.addItem(3, 3, GridItemEnum.turret, @as(*anyopaque, @ptrCast(&t)));

    const itemT = try g.getItem(3, 3);
    try expect(itemT == GridItemEnum.turret);

    const t2 = itemT.turret;
    try compareEntities(t.entity, t2.entity);

    var e = Enemy.init(.{
        .x = 42,
        .y = 42,
        .w = 32,
        .h = 32,
    });
    defer e.deinit();
    try g.addItem(4, 4, GridItemEnum.enemy, @as(*anyopaque, @ptrCast(&e)));

    const itemE = try g.getItem(4, 4);
    try expect(itemE == GridItemEnum.enemy);

    const e2 = itemE.enemy;
    try compareEntities(e.entity, e2.entity);
}

test "It should get an item" {
    var g = try Grid.init(32, 32);
    defer g.deinit();

    var t = Turret.new(utils.Rectangle{
        .x = 42,
        .y = 42,
        .w = 32,
        .h = 32,
    });
    try g.addItem(3, 3, GridItemEnum.turret, @as(*anyopaque, @ptrCast(&t)));
    const itemT = try g.getItem(3, 3);

    const t2 = itemT.turret;
    try compareEntities(t.entity, t2.entity);

    var e = Enemy.init(utils.Rectangle{
        .x = 42,
        .y = 42,
        .w = 32,
        .h = 32,
    });
    defer e.deinit();
    try g.addItem(4, 4, GridItemEnum.enemy, @as(*anyopaque, @ptrCast(&e)));
    const itemE = try g.getItem(4, 4);

    const e2 = itemE.enemy;
    try compareEntities(e.entity, e2.entity);
}

test "It should map world point to grid" {
    const g = try Grid.init(3, 4);
    defer g.deinit();

    // WorldSize = (30, 40)
    const worldPoint1 = utils.Point{ .x = 20, .y = 10 };
    const cellSize: f32 = 5;

    const gridOffset = utils.Point{ .x = 10, .y = 10 };

    var gridPoint = g.worldToGrid(worldPoint1, gridOffset, cellSize);

    if (gridPoint) |gp| {
        try expect(gp.x == 2);
        try expect(gp.y == 0);
    } else {
        try expect(false);
    }

    // Out of bounds (min)
    const worldPoint2 = utils.Point{ .x = 0, .y = 0 };
    gridPoint = g.worldToGrid(worldPoint2, gridOffset, cellSize);
    // Should be null
    if (gridPoint) |_| {
        try expect(false);
    }

    // Out of bounds max()
    const worldPoint3 = utils.Point{ .x = 10, .y = 40 };
    gridPoint = g.worldToGrid(worldPoint3, gridOffset, cellSize);
    // Should be null
    if (gridPoint) |_| {
        try expect(false);
    }
}
