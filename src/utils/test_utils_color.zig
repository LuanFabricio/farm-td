const std = @import("std");
const expect = std.testing.expect;

const Color = @import("utils.zig").Color;

test "It should cast to Raylib color struct" {
    const colorR = Color{
        .r = 0xff,
        .g = 0x00,
        .b = 0x00,
        .a = 0x00,
    };

    const colorRRaylib = colorR.toRayColor();

    try expect(colorR.r == colorRRaylib.r);
    try expect(colorR.g == colorRRaylib.g);
    try expect(colorR.b == colorRRaylib.b);
    try expect(colorR.a == colorRRaylib.a);

    const colorG = Color{
        .r = 0x00,
        .g = 0xff,
        .b = 0x00,
        .a = 0x00,
    };

    const colorGRaylib = colorG.toRayColor();

    try expect(colorG.r == colorGRaylib.r);
    try expect(colorG.g == colorGRaylib.g);
    try expect(colorG.b == colorGRaylib.b);
    try expect(colorG.a == colorGRaylib.a);

    const colorB = Color{
        .r = 0x00,
        .g = 0x00,
        .b = 0xff,
        .a = 0x00,
    };

    const colorBRaylib = colorB.toRayColor();

    try expect(colorB.r == colorBRaylib.r);
    try expect(colorB.g == colorBRaylib.g);
    try expect(colorB.b == colorBRaylib.b);
    try expect(colorB.a == colorBRaylib.a);

    const color = Color{
        .r = 0xaa,
        .g = 0xaa,
        .b = 0xaa,
        .a = 0xaa,
    };
    const colorRaylib = color.toRayColor();

    try expect(color.r == colorRaylib.r);
    try expect(color.g == colorRaylib.g);
    try expect(color.b == colorRaylib.b);
    try expect(color.a == colorRaylib.a);
}
