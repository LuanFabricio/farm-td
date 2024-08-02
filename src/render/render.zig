const std = @import("std");

const utils = @import("../utils/utils.zig");
const Raylib = utils.Raylib;
const Color = utils.Color;
const Rectangle = utils.Rectangle;
const Point = utils.Point;

const spriteImport = @import("sprite.zig");
const SpriteSheet = spriteImport.SpriteSheet;

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

    pub fn drawLineP(_: *const Render, p1: Point, p2: Point, color: Color) void {
        const rayColor = color.toRayColor();
        const p1RayVec2 = p1.toRayVec2();
        const p2RayVec2 = p2.toRayVec2();

        Raylib.DrawLineV(p1RayVec2, p2RayVec2, rayColor);
    }

    pub fn drawCircleLinesP(_: *const Render, center: Point, radius: f32, color: Color) void {
        const rayColor = color.toRayColor();
        const centerRayVec2 = center.toRayVec2();

        Raylib.DrawCircleLinesV(centerRayVec2, radius, rayColor);
    }

    pub fn drawText(_: *const Render, text: [:0]const u8, fontSize: u32, position: utils.Point, color: Color) void {
        const rayColor = color.toRayColor();

        const x: c_int = @intFromFloat(position.x);
        const y: c_int = @intFromFloat(position.y);
        Raylib.DrawText(text, x, y, @as(c_int, @intCast(fontSize)), rayColor);
    }

    pub fn drawSpriteSheet(_: *const Render, position: utils.Point, spriteSheet: SpriteSheet, row: usize, col: usize) void {
        const rayRect = spriteSheet.getSpriteRect(row, col).toRayRect();
        const tint = Raylib.Color{
            .r = 0xff,
            .g = 0xff,
            .b = 0xff,
            .a = 0xff,
        };
        const rayPosition = position.toRayVec2();

        Raylib.DrawTextureRec(spriteSheet.sheet, rayRect, rayPosition, tint);
    }

    pub fn getFrameTime(_: *const Render) f32 {
        return Raylib.GetFrameTime();
    }
};
// TODO(luan): Creste a texture render
// TODO(luan): Creste an animation module
