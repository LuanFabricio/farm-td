const std = @import("std");
const expect = std.testing.expect;

const utils = @import("utils.zig");
const Point = utils.Point;

test "It should calc a distance between two points" {
    const p1 = Point{ .x = 1, .y = 1 };
    const p2 = Point{ .x = 5, .y = -2 };

    try expect(p1.calcDist(&p2) == 5);
}

test "It should cast to Raylib Vector2" {
    const p = Point{ .x = 5, .y = -5 };

    const rayPoint = p.toRayVec2();
    const expectedRayPoint = utils.Raylib.Vector2{
        .x = 5,
        .y = -5,
    };

    try expect(rayPoint.x == expectedRayPoint.x);
    try expect(rayPoint.y == expectedRayPoint.y);
}

test "It should rotate" {
    const p = Point{ .x = 4, .y = 10 };

    const p0 = p.rotate(0);
    try expect(p0.x == p.x);
    try expect(p0.y == p.y);

    const p90 = p.rotate(90);
    try expect(p90.x == -p.y);
    try expect(p90.y == p.x);

    const p180 = p.rotate(180);
    try expect(p180.x == -p.x);
    try expect(p180.y == -p.y);

    const p270 = p.rotate(270);
    try expect(p270.x == p.y);
    try expect(p270.y == -p.x);

    const p360 = p.rotate(360);
    try expect(p360.x == p.x);
    try expect(p360.y == p.y);
}
