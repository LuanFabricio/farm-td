const std = @import("std");

const utils = @import("utils/utils.zig");

const Entity = @import("core/entity.zig").Entity;
const turret = @import("core/turret.zig");
const enemy = @import("core/enemy.zig");

const Render = @import("render/render.zig").Render;

const input = @import("input/input.zig");
const Input = input.Input;
const KeyEnum = input.KeyEnum;

pub fn main() !void {
    var t = turret.Turret.new(utils.Rectangle{
        .x = 400,
        .y = 300,
        .w = 32,
        .h = 64,
    });

    var e: enemy.Enemy = enemy.Enemy.init(utils.Rectangle{
        .x = 200,
        .y = 300,
        .w = 32,
        .h = 64,
    });
    defer e.deinit();

    try e.addObserver(&t);

    e.notifyAll();

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

    // NOTE: For health example
    const baseRect: utils.Rectangle = .{
        .x = 500,
        .y = 500,
        .w = 400,
        .h = 100,
    };
    const baseColor = utils.Color{
        .r = 0xaa,
        .g = 0xaa,
        .b = 0xaa,
        .a = 0xff,
    };
    const healthColor = utils.Color{
        .r = 0xff,
        .g = 0x00,
        .b = 0x00,
        .a = 0xff,
    };

    while (render.shouldRender()) {
        render.beginDraw();
        defer render.endDraw();

        render.drawRectangleRect(rect, color);

        displayHealth(render, baseRect, baseColor, healthColor, 0.32);

        render.drawRectangleRect(t.entity.box, turret.DEFAULT_COLOR);
        render.drawRectangleRect(e.entity.box, enemy.DEFAULT_COLOR);

        const turretRect = e.entity.healthRect();
        const turretHpP: f32 = e.entity.healthPercentage();
        displayHealth(render, turretRect, baseColor, healthColor, turretHpP);

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

fn displayHealth(render: Render, baseRect: utils.Rectangle, baseColor: utils.Color, healthColor: utils.Color, percentage: f32) void {
    var healthRect = baseRect.clone();
    healthRect.w = baseRect.w * percentage;

    render.drawRectangleRect(baseRect, baseColor);
    healthRect.x += baseRect.w - healthRect.w;
    render.drawRectangleRect(healthRect, healthColor);
}
