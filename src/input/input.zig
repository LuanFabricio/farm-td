const raylib = @cImport({
    @cInclude("/usr/local/include/raylib.h");
    @cInclude("/usr/local/include/raymath.h");
});

pub const KeyEnum = enum(i32) {
    Up,
    Down,
    Left,
    Right,
};

pub const Input = struct {
    pub fn isKeyPressed(keyCode: KeyEnum) bool {
        const raylibKeyCode = Input.keyEnumToRaylib(keyCode);
        return raylib.IsKeyPressed(raylibKeyCode);
    }

    pub fn isKeyDown(keyCode: KeyEnum) bool {
        const raylibKeyCode = Input.keyEnumToRaylib(keyCode);
        return raylib.IsKeyDown(raylibKeyCode);
    }

    fn keyEnumToRaylib(keyCode: KeyEnum) i32 {
        const raylibKeyCode = switch (keyCode) {
            .Up => raylib.KEY_W,
            .Down => raylib.KEY_S,
            .Left => raylib.KEY_A,
            .Right => raylib.KEY_D,
        };

        return raylibKeyCode;
    }
};
