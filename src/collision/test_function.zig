const std = @import("std");
const expect = std.testing.expect;

const utils = @import("../utils/utils.zig");

const functionImport = @import("function.zig");
const Function = functionImport.Function;

test "It should be created from two points" {
    const p11 = utils.Point{ .x = 0, .y = 0 };
    const p12 = utils.Point{ .x = 1, .y = 0 };

    const function1 = Function.fromPoints(p11, p12);

    try expect(function1.a == 0.0);
    try expect(function1.b == 0.0);
    try expect(function1.mainAxis == Function.Axis.X);

    const p21 = utils.Point{ .x = 0, .y = 0 };
    const p22 = utils.Point{ .x = 1, .y = 1 };

    const function2 = Function.fromPoints(p21, p22);

    try expect(function2.a == 1.0);
    try expect(function2.b == 0.0);
    try expect(function2.mainAxis == Function.Axis.X);

    const p31 = utils.Point{ .x = 3.5, .y = -4 };
    const p32 = utils.Point{ .x = 1.5, .y = 1 };

    const function3 = Function.fromPoints(p31, p32);

    try expect(function3.a == -2.5);
    try expect(function3.b == 4.75);
    try expect(function3.mainAxis == Function.Axis.X);

    const p41 = utils.Point{ .x = 4, .y = -4 };
    const p42 = utils.Point{ .x = 4, .y = 1 };

    const function4 = Function.fromPoints(p41, p42);

    try expect(function4.a == 0.0);
    try expect(function4.b == 4.0);
    try expect(function4.mainAxis == Function.Axis.Y);
}

test "It should check if other function collides" {
    const func11 = Function{ .a = 0.0, .b = 4.0, .mainAxis = Function.Axis.X };
    const func12 = Function{ .a = 42.0, .b = 4.0, .mainAxis = Function.Axis.X };

    try expect(func11.canCollide(func12));

    const func21 = Function{ .a = 0.0, .b = 4.0, .mainAxis = Function.Axis.X };
    const func22 = Function{ .a = 0.0, .b = 4.0, .mainAxis = Function.Axis.Y };

    try expect(func21.canCollide(func22));

    const func31 = Function{ .a = 3, .b = 4.0, .mainAxis = Function.Axis.X };
    const func32 = Function{ .a = 3, .b = 4.0, .mainAxis = Function.Axis.X };
    try expect(!func31.canCollide(func32));
}

test "It should get the point of collisio" {
    // TODO(luan): Write collidePoint test.
}
