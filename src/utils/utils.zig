const Pi = @import("std").math.pi;

pub const Raylib = @cImport({
    @cInclude("raylib.h");
    @cInclude("raymath.h");
    @cInclude("rlgl.h");
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
    const This = @This();
    const radCast: f64 = Pi / 180.0;
    x: f32,
    y: f32,

    pub fn calcDist(self: *const Point, other: *const Point) f32 {
        const dx = self.x - other.x;
        const dy = self.y - other.y;

        const squaredDist = dx * dx + dy * dy;
        return @sqrt(squaredDist);
    }

    pub fn toRayVec2(self: *const Point) Raylib.Vector2 {
        return Raylib.Vector2{
            .x = self.x,
            .y = self.y,
        };
    }

    pub fn rotate(self: *const This, angle: f64) This {
        const rad: f64 = radCast * angle;
        const cos = @cos(rad);
        const sin = @sin(rad);
        const rx = self.x * cos - self.y * sin;
        const ry = self.x * sin + self.y * cos;

        return This{
            .x = @as(f32, @floatCast(rx)),
            .y = @as(f32, @floatCast(ry)),
        };
    }
};

pub const Rectangle = struct {
    const This = @This();
    x: f32,
    y: f32,
    w: f32,
    h: f32,

    pub fn fromPoints(p1: Point, p2: Point) This {
        const x1 = @min(p1.x, p2.x);
        const x2 = @max(p1.x, p2.x);
        const y1 = @min(p1.y, p2.y);
        const y2 = @max(p1.y, p2.y);

        return This{
            .x = x1,
            .y = y1,
            .w = x2 - x1,
            .h = y2 - y1,
        };
    }

    pub fn copy(self: *This, other: This) void {
        self.x = other.x;
        self.y = other.y;
        self.w = other.w;
        self.h = other.h;
    }

    pub fn toRayRect(self: *const This) Raylib.Rectangle {
        return .{
            .x = self.x,
            .y = self.y,
            .width = self.w,
            .height = self.h,
        };
    }

    pub fn clone(self: *const This) This {
        return This{
            .x = self.x,
            .y = self.y,
            .w = self.w,
            .h = self.h,
        };
    }

    pub fn containsPoint(self: *const This, point: Point) bool {
        const matchX = point.x >= self.x and point.x <= self.x + self.w;
        const matchY = point.y >= self.y and point.y <= self.y + self.h;

        return matchX and matchY;
    }

    pub fn getCenter(self: *const This) Point {
        const cx = self.x + self.w / 2;
        const cy = self.y + self.h / 2;

        return Point{
            .x = cx,
            .y = cy,
        };
    }

    pub fn getPoints(self: *const This) [4]Point {
        const lt = Point{ .x = self.x, .y = self.y };
        const rt = Point{ .x = self.x + self.w, .y = self.y };
        const lb = Point{ .x = self.x, .y = self.y + self.h };
        const rb = Point{ .x = self.x + self.w, .y = self.y + self.h };

        // Left-Top, Right-Top, Left-Bot, Right-Bot
        return [4]Point{ lt, rt, lb, rb };
    }
};
