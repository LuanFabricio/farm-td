const std = @import("std");
const Allocator = std.heap.page_allocator;
const ArrayList = std.ArrayList;

const Delay = @import("../utils/delay.zig").Delay;

const spriteImport = @import("sprite.zig");
const Sprite = spriteImport.Sprite;

// TODO: Try to use Sprites and SpriteSheets on animation

pub const Animation = struct {
    const This = @This();
    sprites: ArrayList(Sprite),
    currentSprite: usize,
    delay: Delay,
    reverseToLoop: bool,
    onReverse: bool,

    pub fn init(filepath: []const u8, frames: usize, reverseToLoop: bool) !This {
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
            .reverseToLoop = reverseToLoop,
            .onReverse = false,
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

        if (self.onReverse) {
            self.applyReverse();
        } else {
            self.currentSprite += 1;
        }

        if (self.reverseToLoop) {
            if (!self.onReverse and self.currentSprite >= self.sprites.items.len) {
                self.onReverse = true;
                self.currentSprite -= 1;
            }
        } else if (self.currentSprite >= self.sprites.items.len) self.currentSprite = 0;

        self.delay.applyDelay();
    }

    fn applyReverse(self: *This) void {
        if (self.currentSprite != 0) {
            self.currentSprite -= 1;
            return;
        }
        self.currentSprite = 0;
        self.onReverse = false;
    }
};
