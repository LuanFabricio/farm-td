const std = @import("std");

const utils = @import("../utils/utils.zig");
const Raylib = utils.Raylib;
const Color = utils.Color;
const Rectangle = utils.Rectangle;

pub const Render = struct {
    live: bool,

    pub fn init() Render {
        Raylib.InitWindow(1280, 720, "Farm TD");
        Raylib.SetTargetFPS(60);
        return .{
            .live = true,
        };
    }

    pub fn deinit(self: *Render) void {
        self.live = false;
        Raylib.CloseWindow();
    }

    pub fn shouldRender(self: *const Render) bool {
        return !Raylib.WindowShouldClose() and self.live;
    }

    pub fn beginDraw(_: *const Render) void {
        Raylib.BeginDrawing();
        Raylib.ClearBackground(Raylib.BLACK);
    }

    pub fn endDraw(_: *const Render) void {
        defer Raylib.EndDrawing();
    }

    pub fn drawRectangle(_: *const Render, x: i32, y: i32, w: i32, h: i32, color: Color) void {
        const rayColor = color.toRayColor();
        Raylib.DrawRectangle(x, y, w, h, rayColor);
    }

    pub fn drawRectangleRect(_: *const Render, rectangle: Rectangle, color: Color) void {
        const rayColor = color.toRayColor();
        Raylib.DrawRectangleRec(rectangle.toRayRect(), rayColor);
    }

    pub fn getFrameTime(_: *Render) f32 {
        return Raylib.GetFrameTime();
    }
};
