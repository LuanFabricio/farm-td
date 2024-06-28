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

pub const Point = struct {
    x: f32,
    y: f32,

    pub fn calcDist(self: *const Point, other: *const Point) f32 {
        const dx = self.x - other.x;
        const dy = self.y - other.y;

        const squaredDist = dx * dx + dy * dy;
        return @sqrt(squaredDist);
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

    pub fn getCenter(self: *const Rectangle) Point {
        const cx = self.x + self.w / 2;
        const cy = self.y - self.h / 2;

        return Point{
            .x = cx,
            .y = cy,
        };
    }
};
