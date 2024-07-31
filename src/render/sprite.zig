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

pub const SpriteSheet = struct {
    const This = @This();
    sheet: Raylib.Texture2D,
    spriteWidth: usize,
    spriteHeight: usize,
    gridRows: usize,
    gridCols: usize,
    gridPadding: utils.Point,

    pub fn load_sprite_sheet(textureName: [*c]const u8, spriteWidth: usize, spriteHeight: usize, gridRows: usize, gridCols: usize, gridPadding: utils.Point) This {
        const tex = Raylib.LoadTexture(textureName);

        return This{
            .sheet = tex,
            .spriteWidth = spriteWidth,
            .spriteHeight = spriteHeight,
            .gridRows = gridRows,
            .gridCols = gridCols,
            .gridPadding = gridPadding,
        };
    }

    pub fn unload_sprite_sheet(self: This) void {
        Raylib.UnloadTexture(self.sheet);
    }
};
