const std = @import("std");
const expect = std.testing.expect;

const utils = @import("../utils/utils.zig");
const HitBox = @import("hitbox.zig").HitBox;

test "It can collide" {
    const hb = HitBox.new(utils.Rectangle{ .x = 42, .y = 42, .w = 32, .h = 32 });
    const target = HitBox.new(utils.Rectangle{ .x = 52, .y = 52, .w = 32, .h = 32 });
    const speed = utils.Point{ .x = 1, .y = 1 };

    try expect(hb.canCollide(&target, speed));
}

test "It should collide" {
    const hb1 = HitBox.new(utils.Rectangle{ .x = 42, .y = 42, .w = 32, .h = 32 });
    const target1 = HitBox.new(utils.Rectangle{ .x = 52, .y = 52, .w = 32, .h = 32 });

    try expect(hb1.checkCollision(&target1));

    const hb2 = HitBox.new(utils.Rectangle{ .x = 42, .y = 42, .w = 32, .h = 32 });
    const target2 = HitBox.new(utils.Rectangle{ .x = 100, .y = 100, .w = 32, .h = 32 });

    try expect(!hb2.checkCollision(&target2));
}

test "It should collide by step" {
    const hb1 = HitBox.new(utils.Rectangle{ .x = 42, .y = 42, .w = 32, .h = 32 });
    const target1 = HitBox.new(utils.Rectangle{
        .x = hb1.hitbox.x + hb1.hitbox.w + 1,
        .y = hb1.hitbox.y + hb1.hitbox.h + 1,
        .w = 32,
        .h = 32,
    });

    const speed1 = utils.Point{ .x = 1, .y = 1 };

    try expect(hb1.stepCollision(&target1, speed1));

    const hb2 = HitBox.new(utils.Rectangle{ .x = 42, .y = 42, .w = 32, .h = 32 });
    const target2 = HitBox.new(utils.Rectangle{
        .x = hb2.hitbox.x + hb2.hitbox.w + 5,
        .y = hb2.hitbox.y + hb2.hitbox.h + 5,
        .w = 32,
        .h = 32,
    });

    const speed2 = utils.Point{ .x = 5, .y = 5 };

    try expect(hb2.stepCollision(&target2, speed2));
}

test "Collision with angles" {
    var hb1 = HitBox.new(utils.Rectangle{
        .x = 42,
        .y = 42,
        .w = 32,
        .h = 32,
    });
    hb1.angle = 30;

    var hb2 = HitBox.new(utils.Rectangle{
        .x = 56,
        .y = 42,
        .w = 32,
        .h = 32,
    });
    hb2.angle = 45;

    const lines1 = hb1.getLines();
    std.debug.print("Lines1\n", .{});
    for (lines1, 0..) |line, idx| {
        std.debug.print("\tIndex: {d}\n", .{idx});
        std.debug.print("\t\tFunction: {any}\n", .{line.function});
        std.debug.print("\t\tPoint: {any}\n", .{line.points});
    }
    const lines2 = hb2.getLines();
    std.debug.print("Lines2\n", .{});
    for (lines2, 0..) |line, idx| {
        std.debug.print("\tIndex: {d}\n", .{idx});
        std.debug.print("\t\tFunction: {any}\n", .{line.function});
        std.debug.print("\t\tPoint: {any}\n", .{line.points});
    }

    const res = hb1.getIntersections(hb2);
    if (res) |x| {
        std.debug.print("Point: {any}", .{x});
    }
}
