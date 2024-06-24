const std = @import("std");

const raylib = @cImport({
    @cInclude("/usr/local/include/raylib.h");
    @cInclude("/usr/local/include/raymath.h");
});

pub const Render = struct {
    live: bool,

    pub fn init() Render {
        raylib.InitWindow(1280, 720, "Farm TD");
        raylib.SetTargetFPS(60);
        return .{
            .live = true,
        };
    }

    pub fn deinit(self: *Render) void {
        self.live = false;
        raylib.CloseWindow();
    }

    pub fn shouldRender(self: *const Render) bool {
        return !raylib.WindowShouldClose() and self.live;
    }

    pub fn beginDraw(_: *const Render) void {
        raylib.BeginDrawing();
        raylib.ClearBackground(raylib.BLACK);
    }

    pub fn endDraw(_: *const Render) void {
        defer raylib.EndDrawing();
    }

    pub fn drawRectangle(_: *const Render, x: i32, y: i32, w: i32, h: i32, color: [4]u8) void {
        const rayColor = raylib.Color{
            .r = color[0],
            .g = color[1],
            .b = color[2],
            .a = color[3],
        };
        raylib.DrawRectangle(x, y, w, h, rayColor);
    }

    pub fn getFrameTime(_: *Render) f32 {
        return raylib.GetFrameTime();
    }
};
