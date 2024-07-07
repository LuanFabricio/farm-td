const std = @import("std");

const ArrayList = std.ArrayList;
const allocator = std.heap.page_allocator;

const utils = @import("../utils/utils.zig");

const Turret = @import("turret.zig").Turret;
const Enemy = @import("enemy.zig").Enemy;
const Entity = @import("entity.zig").Entity;

pub const Grid = struct {
    width: usize,
    height: usize,
    items: ArrayList(?*Turret),

    pub fn init(width: usize, height: usize) !Grid {
        const len = width * height;

        var g = Grid{
            .width = width,
            .height = height,
            .items = ArrayList(?*Turret).init(allocator),
        };
        try g.items.resize(len);

        var i: usize = 0;
        while (i < len) : (i += 1) {
            g.items.items[i] = null;
        }

        return g;
    }

    pub fn deinit(self: *const Grid) void {
        self.items.deinit();
    }

    pub fn xyToIndex(self: *Grid, x: usize, y: usize) usize {
        return y * self.width + x;
    }

    pub fn addItem(self: *Grid, x: usize, y: usize, turret: *Turret) void {
        const idx = self.xyToIndex(x, y);

        if (idx > self.items.items.len) {
            return;
        }

        if (self.items.items[idx]) |_| {
            return;
        }

        self.items.items[idx] = turret;
    }

    pub fn getItem(self: *Grid, x: usize, y: usize) !?*Turret {
        const idx = self.xyToIndex(x, y);

        if (idx > self.items.items.len) {
            return error.ItemOutOfBounds;
        }
        return self.items.items[idx];
    }

    pub fn worldToGrid(self: *const Grid, worldPoint: utils.Point, gridOffset: utils.Point, cellSize: f32) ?utils.Point {
        const maxX: f32 = @as(f32, @floatFromInt(self.width)) * cellSize + gridOffset.x;
        const maxY: f32 = @as(f32, @floatFromInt(self.height)) * cellSize + gridOffset.y;

        if (worldPoint.x < gridOffset.x or worldPoint.x > maxX or worldPoint.y < gridOffset.y or worldPoint.y > maxY) {
            return null;
        }

        var gridPoint = utils.Point{
            .x = worldPoint.x - gridOffset.x,
            .y = worldPoint.y - gridOffset.y,
        };
        gridPoint.x = @divFloor(gridPoint.x, cellSize);
        gridPoint.y = @divFloor(gridPoint.y, cellSize);

        return gridPoint;
    }
};
