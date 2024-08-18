const std = @import("std");

const utils = @import("../utils/utils.zig");

const epsilonf32 = std.math.floatEps(f32);

pub const Function = struct {
    const This = @This();
    pub const Axis = enum { X, Y };
    a: f32,
    b: f32,
    mainAxis: Axis,

    pub fn fromPoints(p1: utils.Point, p2: utils.Point) This {
        const dx = (p2.x - p1.x);
        const dy = (p2.y - p1.y);

        var mainAxis = Axis.X;
        var d1 = dx;
        var d2 = dy;
        if (@abs(dx) < epsilonf32) {
            d1 = dy;
            d2 = dx;
            mainAxis = Axis.Y;
        }

        const a = d2 / d1;
        const b = switch (mainAxis) {
            Axis.X => p2.y - a * p2.x,
            Axis.Y => p2.x - a * p2.y,
        };
        return This{
            .a = a,
            .b = b,
            .mainAxis = mainAxis,
        };
    }

    pub fn calc(self: *const This, x: f32) f32 {
        return self.a * x + self.b;
    }

    pub fn canCollide(self: *const This, other: This) bool {
        if (self.mainAxis != other.mainAxis) return true;
        return @abs(self.a - other.a) >= epsilonf32;
    }

    pub fn collidePoint(self: *const This, other: This) !utils.Point {
        if (!self.canCollide(other)) return error.CannotCollide;

        if (self.mainAxis == This.Axis.Y) {
            return utils.Point{
                .x = self.b,
                .y = other.calc(self.b),
            };
        } else if (other.mainAxis == This.Axis.Y) {
            return utils.Point{
                .x = other.b,
                .y = self.calc(other.b),
            };
        }

        const x = (other.b - self.b) / (self.a - other.a);
        const y = self.a * x + self.b;

        return utils.Point{
            .x = x,
            .y = y,
        };
    }
};
