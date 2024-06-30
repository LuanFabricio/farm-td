const expect = @import("std").testing.expect;

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
}

test "It should create a new Grid" {
    const w = 32;
    const h = 32;
    const g = Grid.new(w, h);

    const len = w * h;
    try expect(g.width == w);
    try expect(g.height == h);
    try expect(g.items.len == len);
}

test "It should cast an item to Turret" {
    var t = Turret.new(utils.Rectangle{
        .x = 32,
        .y = 32,
        .w = 32,
        .h = 32,
    });

    const item = GridItem{
        .data = @ptrCast(&t),
        .itemType = GridItemEnum.Turret,
    };
    const t2 = Grid.castItemToTurret(item);

    try compareEntities(t.entity, t2.entity);
}

test "It should cast an item to Enemy" {
    var e = Enemy.init(utils.Rectangle{
        .x = 32,
        .y = 32,
        .w = 32,
        .h = 32,
    });
    defer e.deinit();

    const item = GridItem{
        .data = @ptrCast(&e),
        .itemType = GridItemEnum.Enemy,
    };
    const e2 = Grid.castItemToEnemy(item);

    try compareEntities(e.entity, e2.entity);
}

test "It should add an item" {
    var g = Grid.new(32, 32);

    var t = Turret.new(.{
        .x = 42,
        .y = 42,
        .w = 32,
        .h = 32,
    });
    g.addItem(3, 3, GridItemEnum.Turret, @as(*anyopaque, @ptrCast(&t)));

    var idx = g.xyToIndex(3, 3);
    const itemT = g.items[idx];
    try expect(itemT.itemType == GridItemEnum.Turret);

    const t2 = Grid.castItemToTurret(itemT);
    try compareEntities(t.entity, t2.entity);

    var e = Turret.new(.{
        .x = 42,
        .y = 42,
        .w = 32,
        .h = 32,
    });
    g.addItem(4, 4, GridItemEnum.Enemy, @as(*anyopaque, @ptrCast(&e)));

    idx = g.xyToIndex(3, 3);
    const itemE = g.items[idx];
    try expect(itemE.itemType == GridItemEnum.Turret);

    const e2 = Grid.castItemToTurret(itemE);
    try compareEntities(e.entity, e2.entity);
}

test "It should get an item" {
    var g = Grid.new(32, 32);

    var t = Turret.new(utils.Rectangle{
        .x = 42,
        .y = 42,
        .w = 32,
        .h = 32,
    });
    g.addItem(3, 3, GridItemEnum.Turret, @as(*anyopaque, @ptrCast(&t)));
    const itemT = try g.getItem(3, 3);

    const t2 = Grid.castItemToTurret(itemT);
    try compareEntities(t.entity, t2.entity);

    var e = Enemy.init(utils.Rectangle{
        .x = 42,
        .y = 42,
        .w = 32,
        .h = 32,
    });
    defer e.deinit();
    g.addItem(4, 4, GridItemEnum.Enemy, @as(*anyopaque, @ptrCast(&e)));
    const itemE = try g.getItem(4, 4);

    const e2 = Grid.castItemToEnemy(itemE);
    try compareEntities(e.entity, e2.entity);
}
