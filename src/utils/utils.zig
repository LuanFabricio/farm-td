pub const Raylib = @cImport({
    @cInclude("/usr/local/include/raylib.h");
    @cInclude("/usr/local/include/raymath.h");
});

pub const Color = struct {
    r: u8,
    g: u8,
    b: u8,
    a: u8,

    pub fn toRayColor(self: *const Color) Raylib.Color {
        return .{ .r = self.r, .g = self.g, .b = self.b, .a = self.a };
    }
};

pub const Rectangle = struct {
    x: f32,
    y: f32,
    w: f32,
    h: f32,

    pub fn toRayRect(self: *const Rectangle) Raylib.Rectangle {
        return .{
            .x = self.x,
            .y = self.y,
            .width = self.w,
            .height = self.h,
        };
    }
};
