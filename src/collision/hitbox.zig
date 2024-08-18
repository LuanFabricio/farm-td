const std = @import("std");

const utils = @import("../utils/utils.zig");

const functionImport = @import("function.zig");
const Function = functionImport.Function;

pub const HitBox = struct {
    const This = @This();

    hitbox: utils.Rectangle,
    angle: f32,

    pub fn new(hitbox: utils.Rectangle) This {
        return This{
            .hitbox = hitbox,
            .angle = 0.0,
        };
    }

    pub fn stepCollision(self: *const This, target: *const This, speed: utils.Point) bool {
        if (!self.canCollide(target, speed)) return false;

        const baseRect: utils.Rectangle = self.hitbox;

        const baseHb = This.new(baseRect);
        var hb = This.new(baseRect);
        const stepSize = 12;
        const step: f32 = 1.0 / @as(f32, @floatFromInt(stepSize));
        for (1..stepSize + 1) |idx| {
            const currentSpeedStep = step * @as(f32, @floatFromInt(idx));
            const lastSpeedStep = step * @as(f32, @floatFromInt(idx - 1));

            hb.hitbox.x = baseHb.hitbox.x + speed.x * currentSpeedStep;
            hb.hitbox.y = baseHb.hitbox.y + speed.y * lastSpeedStep;
            if (hb.checkCollision(target)) return true;

            hb.hitbox.x = baseHb.hitbox.x + speed.x * lastSpeedStep;
            hb.hitbox.y = baseHb.hitbox.y + speed.y * currentSpeedStep;
            if (hb.checkCollision(target)) return true;

            hb.hitbox.y = baseHb.hitbox.y + speed.y * currentSpeedStep;
            hb.hitbox.x = baseHb.hitbox.x + speed.x * currentSpeedStep;
            if (hb.checkCollision(target)) return true;
        }

        return false;
    }

    pub fn checkCollision(self: *const This, target: *const This) bool {
        const rightLeft = self.hitbox.x + self.hitbox.w >= target.hitbox.x;
        const leftRight = self.hitbox.x <= target.hitbox.x + target.hitbox.x;
        const bottomUp = self.hitbox.y + self.hitbox.h >= target.hitbox.y;
        const upBottom = self.hitbox.y <= target.hitbox.y + target.hitbox.h;

        return rightLeft and leftRight and bottomUp and upBottom;
    }

    pub fn canCollide(self: *const This, target: *const This, speed: utils.Point) bool {
        const dx = target.hitbox.x - self.hitbox.x;
        const dy = target.hitbox.y - self.hitbox.y;

        const dxSignal = @as(u32, @bitCast(dx)) & 0x80000000;
        const speedXSignal = @as(u32, @bitCast(speed.x)) & 0x80000000;
        const xSampleSignal = dxSignal == speedXSignal;

        const dySignal = @as(u32, @bitCast(dy)) & 0x80000000;
        const speedYSignal = @as(u32, @bitCast(speed.y)) & 0x80000000;
        const ySampleSignal = dySignal == speedYSignal;

        return xSampleSignal and ySampleSignal;
    }

    const Lines = struct {
        function: Function,
        points: [2]utils.Point,
    };
    pub fn getLines(self: *const This) [4]Lines {
        var copyBox = self.hitbox.clone();
        copyBox.x = -copyBox.w / 2;
        copyBox.y = -copyBox.h / 2;

        var points = copyBox.getPoints();
        for (&points) |*point| {
            point.* = point.rotate(self.angle);
            point.x += self.hitbox.x + self.hitbox.w / 2;
            point.y += self.hitbox.y + self.hitbox.h / 2;
        }

        return [4]Lines{
            .{ .function = Function.fromPoints(points[1], points[0]), .points = [2]utils.Point{ points[1], points[0] } },
            .{ .function = Function.fromPoints(points[2], points[0]), .points = [2]utils.Point{ points[2], points[0] } },
            .{ .function = Function.fromPoints(points[3], points[1]), .points = [2]utils.Point{ points[3], points[1] } },
            .{ .function = Function.fromPoints(points[3], points[2]), .points = [2]utils.Point{ points[3], points[2] } },
        };
    }

    pub fn getIntersections(self: *const This, other: This) ?utils.Point {
        const selfLines = self.getLines();
        const otherLines = other.getLines();

        for (0..selfLines.len) |selfIdx| {
            const selfLine = selfLines[selfIdx];
            const maxSelfLineX = @max(selfLine.points[0].x, selfLine.points[1].x);
            const minSelfLineX = @min(selfLine.points[0].x, selfLine.points[1].x);
            const maxSelfLineY = @max(selfLine.points[0].y, selfLine.points[1].y);
            const minSelfLineY = @min(selfLine.points[0].y, selfLine.points[1].y);

            for (0..otherLines.len) |otherIdx| {
                const otherLine = otherLines[otherIdx];
                const maxOtherLineX = @max(otherLine.points[0].x, otherLine.points[1].x);
                const minOtherLineX = @min(otherLine.points[0].x, otherLine.points[1].x);
                const maxOtherLineY = @max(otherLine.points[0].y, otherLine.points[1].y);
                const minOtherLineY = @min(otherLine.points[0].y, otherLine.points[1].y);

                std.debug.print("[0]Line: {d} {d}\n", selfLine.points[0]);
                std.debug.print("[1]Line: {d} {d}\n", selfLine.points[1]);
                std.debug.print("[0]Other: {d} {d}\n", otherLine.points[0]);
                std.debug.print("[1]Other: {d} {d}\n", otherLine.points[1]);

                const point = selfLine.function.collidePoint(otherLine.function) catch continue;
                std.debug.print("[{d} x {d}][Before check]Point: {d} {d}\n", .{
                    selfIdx,
                    otherIdx,
                    point.x,
                    point.y,
                });

                const selfCollideX = minSelfLineX <= point.x and point.x <= maxSelfLineX;
                const selfCollideY = minSelfLineY <= point.y and point.y <= maxSelfLineY;

                const otherCollideX = minOtherLineX <= point.x and point.x <= maxOtherLineX;
                const otherCollideY = minOtherLineY <= point.y and point.y <= maxOtherLineY;

                if (selfCollideX and selfCollideY and otherCollideX and otherCollideY) {
                    std.debug.print("Point at {d} x {d}\n", .{ selfIdx, otherIdx });
                    return point;
                }
            }
        }

        return null;
    }
};
