const std = @import("std");

const ArrayList = std.ArrayList;
const allocator = std.heap.page_allocator;

const utils = @import("../utils/utils.zig");

const Turret = @import("turret.zig").Turret;
const Enemy = @import("enemy.zig").Enemy;
const Entity = @import("entity.zig").Entity;

pub fn Grid(comptime value_type: type) type {
    return struct {
        const This = @This();
        width: usize,
        height: usize,
        items: ArrayList(?*value_type),

        pub fn init(width: usize, height: usize) !This {
            var g = This{
                .width = width,
                .height = height,
                .items = ArrayList(?*value_type).init(allocator),
            };

            const len = width * height;
            try g.items.resize(len);

            @memset(g.items.items, null);

            return g;
        }

        pub fn deinit(self: *const This) void {
            self.items.deinit();
        }

        pub fn xyToIndex(self: *This, x: usize, y: usize) usize {
            return y * self.width + x;
        }

        pub fn indexToXY(self: *const This, idx: usize) utils.Point {
            const y: usize = idx / self.width;
            const x: usize = idx % self.width;

            return utils.Point{
                .x = @as(f32, @floatFromInt(x)),
                .y = @as(f32, @floatFromInt(y)),
            };
        }

        pub fn addItem(self: *This, x: usize, y: usize, turret: *value_type) void {
            const idx = self.xyToIndex(x, y);
            if (idx > self.items.items.len and self.items.items[idx] != null) return;

            self.items.items[idx] = turret;
        }

        pub fn getItem(self: *This, x: usize, y: usize) !?*value_type {
            const idx = self.xyToIndex(x, y);

            if (idx > self.items.items.len) {
                return error.ItemOutOfBounds;
            }
            return self.items.items[idx];
        }

        pub fn getItems(self: *const This) []?*value_type {
            return self.items.items;
        }

        pub fn worldToGrid(self: *const This, worldPoint: utils.Point, gridOffset: utils.Point, cellSize: f32) ?utils.Point {
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

        pub fn gridToWorld(_: *const This, gridPoint: utils.Point, offset: utils.Point, gridSize: usize) utils.Point {
            const x = gridPoint.x * @as(f32, @floatFromInt(gridSize)) + offset.x;
            const y = gridPoint.y * @as(f32, @floatFromInt(gridSize)) + offset.y;

            return utils.Point{
                .x = x,
                .y = y,
            };
        }
    };
}
