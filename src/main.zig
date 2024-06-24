const std = @import("std");

const utils = @import("utils/utils.zig");

const Render = @import("render/render.zig").Render;
const input = @import("input/input.zig");
const Input = input.Input;
const KeyEnum = input.KeyEnum;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.writeAll("Hello world!\n");

    var render = Render.init();
    defer render.deinit();

    var rect = utils.Rectangle{
        .x = 42,
        .y = 42,
        .w = 128,
        .h = 128,
    };
    const color = utils.Color{
        .r = 0x19,
        .g = 0x19,
        .b = 0xff,
        .a = 0xff,
    };

    while (render.shouldRender()) {
        render.beginDraw();
        defer render.endDraw();

        render.drawRectangleRect(rect, color);

        const speed = rect.w;
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
        rect.x += xSpeed * frameTime;
        rect.y += ySpeed * frameTime;
    }
}
