const std = @import("std");

const ArrayList = std.ArrayList;
const allocator = std.heap.page_allocator;

const utils = @import("../utils/utils.zig");

const Turret = @import("turret.zig").Turret;
const Enemy = @import("enemy.zig").Enemy;
const Entity = @import("entity.zig").Entity;

pub const GridItemEnum = enum(u8) {
    empty = 0,
    enemy = 1,
    turret = 2,
};

pub const GridItem = union(GridItemEnum) {
    empty: u8,
    enemy: *Enemy,
    turret: *Turret,
};

pub const Grid = struct {
    width: usize,
    height: usize,
    items: ArrayList(GridItem),

    pub fn init(width: usize, height: usize) !Grid {
        const len = width * height;

        var g = Grid{
            .width = width,
            .height = height,
            .items = ArrayList(GridItem).init(allocator),
        };
        try g.items.resize(len);

        var i: usize = 0;
        while (i < len) : (i += 1) {
            g.items.items[i] = GridItem{ .empty = 0 };
        }

        return g;
    }

    pub fn deinit(self: *const Grid) void {
        self.items.deinit();
    }

    pub fn xyToIndex(self: *Grid, x: usize, y: usize) usize {
        return y * self.width + x;
    }

    pub fn addItem(self: *Grid, x: usize, y: usize, itemType: GridItemEnum, item: *anyopaque) !void {
        const idx = self.xyToIndex(x, y);

        if (idx > self.items.items.len) {
            return error.ItemOutOfBounds;
        }

        const gridItem = switch (itemType) {
            .turret => GridItem{ .turret = @as(*Turret, @ptrCast(@alignCast(item))) },
            .enemy => GridItem{ .enemy = @as(*Enemy, @ptrCast(@alignCast(item))) },
            .empty => GridItem{ .empty = 0 },
        };

        self.items.items[idx] = gridItem;
    }

    pub fn getItem(self: *Grid, x: usize, y: usize) !GridItem {
        const idx = self.xyToIndex(x, y);

        if (idx > self.items.items.len) {
            return error.ItemOutOfBounds;
        }
        return self.items.items[idx];
    }
};
