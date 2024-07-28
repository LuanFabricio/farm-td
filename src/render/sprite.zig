const utils = @import("../utils/utils.zig");
const Raylib = utils.Raylib;

pub const Sprite = struct {
    const This = @This();
    content: Raylib.Texture2D,
    width: usize,
    height: usize,

    pub fn load_texture(textureName: [*c]const u8) This {
        const tex = Raylib.LoadTexture(textureName);
        const width: usize = @intCast(tex.width);
        const height: usize = @intCast(tex.height);
        return This{
            .content = tex,
            .width = width,
            .height = height,
        };
    }

    pub fn unload_texture(self: *const This) void {
        Raylib.UnloadTexture(self.content);
    }
};
