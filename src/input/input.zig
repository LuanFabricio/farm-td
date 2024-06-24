const Raylib = @import("../utils/utils.zig").Raylib;

pub const KeyEnum = enum(i32) {
    Up,
    Down,
    Left,
    Right,
};

pub const Input = struct {
    pub fn isKeyPressed(keyCode: KeyEnum) bool {
        const RaylibKeyCode = Input.keyEnumToRaylib(keyCode);
        return Raylib.IsKeyPressed(RaylibKeyCode);
    }

    pub fn isKeyDown(keyCode: KeyEnum) bool {
        const RaylibKeyCode = Input.keyEnumToRaylib(keyCode);
        return Raylib.IsKeyDown(RaylibKeyCode);
    }

    fn keyEnumToRaylib(keyCode: KeyEnum) i32 {
        const RaylibKeyCode = switch (keyCode) {
            .Up => Raylib.KEY_W,
            .Down => Raylib.KEY_S,
            .Left => Raylib.KEY_A,
            .Right => Raylib.KEY_D,
        };

        return RaylibKeyCode;
    }
};
