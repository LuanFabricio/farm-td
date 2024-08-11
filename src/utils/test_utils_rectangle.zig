const std = @import("std");
const expect = std.testing.expect;

const utils = @import("utils.zig");
const Rectangle = utils.Rectangle;

fn compareRects(r1: Rectangle, r2: Rectangle) !void {
    try expect(r1.x == r2.x);
    try expect(r1.y == r2.y);
    try expect(r1.w == r2.w);
    try expect(r1.h == r2.h);
}

fn compareRectsRaylib(r1: Rectangle, r2: utils.Raylib.Rectangle) !void {
    try expect(r1.x == r2.x);
    try expect(r1.y == r2.y);
    try expect(r1.w == r2.width);
    try expect(r1.h == r2.height);
}

test "It should copy another rectangle" {
    var r1 = Rectangle{ .x = 0, .y = 0, .w = 0, .h = 0 };
    const r2 = Rectangle{ .x = 8, .y = 8, .w = 8, .h = 8 };
    r1.copy(r2);

    try compareRects(r1, r2);
}

test "It should create a clone" {
    const r = Rectangle{ .x = 8, .y = 8, .w = 8, .h = 8 };
    try compareRects(r, r.clone());
}

test "It should be converted to Raylib rectangle" {
    const r = Rectangle{ .x = 8, .y = 8, .w = 10, .h = 8 };
    const expectedRayRect = utils.Raylib.Rectangle{
        .x = 8,
        .y = 8,
        .width = 10,
        .height = 8,
    };

    try compareRectsRaylib(r, expectedRayRect);
}

test "It should get the center" {
    const r = Rectangle{ .x = 8, .y = 8, .w = 8, .h = 4 };

    const center = r.getCenter();
    const expectedCenter = utils.Point{ .x = 12, .y = 10 };

    try expect(center.x == expectedCenter.x);
    try expect(center.y == expectedCenter.y);
}

test "It should get the rectangle points" {
    const r = Rectangle{ .x = 8, .y = 16, .w = 4, .h = 8 };

    const points = r.getPoints();
    const expectedPoints = [4]utils.Point{
        utils.Point{ .x = 8, .y = 16 },
        utils.Point{ .x = 12, .y = 16 },
        utils.Point{ .x = 8, .y = 24 },
        utils.Point{ .x = 12, .y = 24 },
    };

    try expect(points[0].x == expectedPoints[0].x);
    try expect(points[0].y == expectedPoints[0].y);

    try expect(points[1].x == expectedPoints[1].x);
    try expect(points[1].y == expectedPoints[1].y);

    try expect(points[2].x == expectedPoints[2].x);
    try expect(points[2].y == expectedPoints[2].y);

    try expect(points[3].x == expectedPoints[3].x);
    try expect(points[3].y == expectedPoints[3].y);
}
