const std = @import("std");
const expect = std.testing.expect;

const utils = @import("../utils/utils.zig");
const Turret = @import("turret.zig").Turret;
const Enemy = @import("enemy.zig").Enemy;
const Entity = @import("entity.zig").Entity;

const grid = @import("grid.zig");
const Grid = grid.Grid;

fn compareEntities(e1: Entity, e2: Entity) !void {
    try expect(e1.status.isEqual(e2.status));
    try expect(e1.defaultStatus.isEqual(e2.defaultStatus));
}

test "It should create a new Grid" {
    const w = 32;
    const h = 32;
    const g = try Grid(void).init(w, h);
    defer g.deinit();

    const len = w * h;
    try expect(g.width == w);
    try expect(g.height == h);
    try expect(g.items.items.len == len);
}

test "It should add an item" {
    var g = try Grid(Turret).init(32, 32);
    defer g.deinit();

    const t = try Turret.init();

    g.addItem(3, 3, t);

    const itemT = try g.getItem(3, 3);
    if (itemT) |item| {
        try compareEntities(t.entity, item.entity);
    } else {
        try expect(false);
    }
}

test "It should throw an error if try to get an item on a not avaliable grid" {
    var g = try Grid(Turret).init(3, 3);
    defer g.deinit();

    const t = try Turret.init();

    g.addItem(2, 2, t);

    if (g.getItem(4, 4)) |_| {
        try expect(false);
    } else |_| {
        try expect(true);
    }
}

test "It should get an item" {
    var g = try Grid(Turret).init(32, 32);
    defer g.deinit();

    const t = try Turret.init();
    g.addItem(3, 3, t);
    const itemT = try g.getItem(3, 3);

    if (itemT) |t2| {
        try compareEntities(t.entity, t2.entity);
    } else {
        try expect(false);
    }
}

test "It should map world point to grid" {
    const g = try Grid(Turret).init(3, 4);
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
