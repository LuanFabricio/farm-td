pub const Raylib = @cImport({
    @cInclude("raylib.h");
    @cInclude("raymath.h");
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

    pub fn clone(self: *const Rectangle) Rectangle {
        return Rectangle{
            .x = self.x,
            .y = self.y,
            .w = self.w,
            .h = self.h,
        };
    }
};
