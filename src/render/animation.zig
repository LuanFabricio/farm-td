const std = @import("std");
const Allocator = std.heap.page_allocator;
const ArrayList = std.ArrayList;

const Delay = @import("../utils/delay.zig").Delay;

const spriteImport = @import("sprite.zig");
const Sprite = spriteImport.Sprite;

pub const Animation = struct {
    const This = @This();
    sprites: ArrayList(Sprite),
    currentSprite: usize,
    delay: Delay,

    pub fn init(filepath: []const u8, frames: usize) !This {
        var sprites = ArrayList(Sprite).init(Allocator);

        for (1..(frames + 1)) |idx| {
            const file = try std.fmt.allocPrintZ(Allocator, "{s}{d}.png", .{ filepath, idx });
            defer Allocator.free(file);
            try sprites.append(Sprite.load_texture(file));
        }

        return This{
            .sprites = sprites,
            .currentSprite = 0,
            .delay = Delay.new(500, true),
        };
    }

    pub fn deinit(self: *const This) void {
        for (self.sprites.items) |sprite| {
            sprite.unload_texture();
        }
        self.sprites.deinit();
    }

    pub fn nextSprite(self: *This) void {
        if (self.delay.onCooldown()) return;

        self.currentSprite = (self.currentSprite + 1) % self.sprites.items.len;
        self.delay.applyDelay();
    }
};
