const utils = @import("../utils/utils.zig");
const Raylib = utils.Raylib;

pub const Sprite = struct {
    const This = @This();
    content: Raylib.Texture2D,

    pub fn load_texture(textureName: [*c]const u8) This {
        return This{
            .content = Raylib.LoadTexture(textureName),
        };
    }

    pub fn unload_texture(self: *const This) void {
        Raylib.UnloadTexture(self.content);
    }
};
