const std = @import("std");

const raylib = @cImport({
    @cInclude("/usr/local/include/raylib.h");
    @cInclude("/usr/local/include/raymath.h");
});

const Render = @import("render/render.zig").Render;
const input = @import("input/input.zig");
const Input = input.Input;
const KeyEnum = input.KeyEnum;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.writeAll("Hello world!\n");

    var render = Render.init();
    defer render.deinit();

    var x: f32 = 42;
    var y: f32 = 42;
    const w: i32 = 128;
    const h: i32 = 128;
    const color = [4]u8{ 0xFF, 0x19, 0x19, 0xFF };

    while (render.shouldRender()) {
        render.beginDraw();
        defer render.endDraw();

        render.drawRectangle(@intFromFloat(x), @intFromFloat(y), w, h, color);

        const speed = w;
        var ySpeed: f32 = 0;
        var xSpeed: f32 = 0;

        if (Input.isKeyDown(.Up)) {
            ySpeed -= speed;
        }
        if (Input.isKeyDown(.Down)) {
            ySpeed += speed;
        }
        if (Input.isKeyDown(.Left)) {
            xSpeed -= speed;
        }
        if (Input.isKeyDown(.Right)) {
            xSpeed += speed;
        }

        const frameTime = render.getFrameTime();
        x += xSpeed * frameTime;
        y += ySpeed * frameTime;
    }
}
