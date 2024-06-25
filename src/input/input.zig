const Raylib = @import("../utils/utils.zig").Raylib;

pub const KeyEnum = enum(i32) {
    Up,
    Down,
    Left,
    Right,
};

pub const MouseBntEnum = enum(i32) {
    Left,
    Middle,
    Right,
};

pub const Input = struct {
    pub fn isKeyPressed(keyCode: KeyEnum) bool {
        const raylibKeyCode = Input.keyEnumToRaylib(keyCode);
        return Raylib.IsKeyPressed(raylibKeyCode);
    }

    pub fn isKeyDown(keyCode: KeyEnum) bool {
        const raylibKeyCode = Input.keyEnumToRaylib(keyCode);
        return Raylib.IsKeyDown(raylibKeyCode);
    }

    fn keyEnumToRaylib(keyCode: KeyEnum) i32 {
        const raylibKeyCode = switch (keyCode) {
            .Up => Raylib.KEY_W,
            .Down => Raylib.KEY_S,
            .Left => Raylib.KEY_A,
            .Right => Raylib.KEY_D,
        };

        return raylibKeyCode;
    }

    pub fn isMouseBntPressed(mouse: MouseBntEnum) bool {
        const raylibMouseCode = Input.mouseEnumToRaylib(mouse);
        return Raylib.IsMouseButtonPressed(raylibMouseCode);
    }

    fn mouseEnumToRaylib(mouse: MouseBntEnum) i32 {
        const raylibMouseBntCode = switch (mouse) {
            .Left => Raylib.MOUSE_BUTTON_LEFT,
            .Right => Raylib.MOUSE_BUTTON_RIGHT,
            .Middle => Raylib.MOUSE_BUTTON_MIDDLE,
        };
        return raylibMouseBntCode;
    }
};
