const expect = @import("std").testing.expect;

const utils = @import("../utils/utils.zig");
const Turret = @import("turret.zig").Turret;

const grid = @import("grid.zig");
const Grid = grid.Grid;
const GridItemEnum = grid.GridItemEnum;

test "It should create a new Grid" {
    const w = 32;
    const h = 32;
    const g = Grid.new(w, h);

    const len = w * h;
    try expect(g.width == w);
    try expect(g.height == h);
    try expect(g.items.len == len);
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

    const idx = 3 * g.width + 3;
    const item = g.items[idx];
    try expect(item.itemType == GridItemEnum.Turret);
}
