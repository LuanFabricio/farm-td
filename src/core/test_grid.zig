const expect = @import("std").testing.expect;

const grid = @import("grid.zig");

const Grid = grid.Grid;

test "It should create a new Grid" {
    const g = Grid.new(32, 32);

    try expect(g.width == 32);
    try expect(g.height == 32);
    try expect(g.items.len == 32 * 32);
}
