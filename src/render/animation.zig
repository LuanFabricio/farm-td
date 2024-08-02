const std = @import("std");
const Allocator = std.heap.page_allocator;
const ArrayList = std.ArrayList;

const utils = @import("../utils/utils.zig");

const Delay = @import("../utils/delay.zig").Delay;

const Render = @import("render.zig").Render;

const spriteImport = @import("sprite.zig");
const Sprite = spriteImport.Sprite;
const SpriteSheet = spriteImport.SpriteSheet;

// TODO: Try to use Sprites and SpriteSheets on animation

// const _Animation = struct { };

pub fn _Animation(
    value_type: type,
    initFn: fn ([:0]const u8, [2]usize, [2]usize, utils.Point) value_type,
    deinitFn: fn (sprites: *value_type) void,
    maxSpritesFn: fn (sprites: value_type) usize,
) type {
    return struct {
        const This = @This();

        sprites: value_type,
        currentSprite: usize,
        delay: Delay,
        reverseToLoop: bool,
        onReverse: bool,
        maxSprites: usize,

        pub fn init(
            filename: [:0]const u8,
            spriteSize: [2]usize,
            gridSize: [2]usize,
            spritePadding: utils.Point,
            delay: Delay,
            reverseToLoop: bool,
        ) This {
            const sprites = initFn(filename, spriteSize, gridSize, spritePadding);
            return This{
                .sprites = sprites,
                .maxSprites = maxSpritesFn(sprites),
                .currentSprite = 0,
                .delay = delay,
                .reverseToLoop = reverseToLoop,
                .onReverse = false,
            };
        }

        pub fn deinit(self: *This) void {
            deinitFn(&self.sprites);
        }

        pub fn nextSprite(self: *This) void {
            if (self.delay.onCooldown()) return;

            if (self.onReverse) {
                self.applyReverse();
            } else {
                self.currentSprite += 1;
            }

            const shouldReset = self.currentSprite >= self.maxSprites;
            const shouldReverse = !self.onReverse and shouldReset;
            if (self.reverseToLoop and shouldReverse) {
                self.onReverse = true;
                self.currentSprite -= 1;
            } else if (!self.reverseToLoop and shouldReset) self.currentSprite = 0;

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
}

fn _initAnimation1(filename: [:0]const u8, sprtSize: [2]usize, gridSize: [2]usize, sprtPadding: utils.Point) SpriteSheet {
    return SpriteSheet.load_sprite_sheet(filename, sprtSize[0], sprtSize[1], gridSize[0], gridSize[1], sprtPadding);
}

fn _deinitAnimation1(sprites: *SpriteSheet) void {
    sprites.unload_sprite_sheet();
}

fn _maxSpritesFn(sprites: SpriteSheet) usize {
    return sprites.gridRows * sprites.gridCols;
}

pub const Animation1 = _Animation(SpriteSheet, _initAnimation1, _deinitAnimation1, _maxSpritesFn);

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

        const shouldReset = self.currentSprite >= self.sprites.items.len;
        const shouldReverse = !self.onReverse and shouldReset;
        if (self.reverseToLoop and shouldReverse) {
            self.onReverse = true;
            self.currentSprite -= 1;
        } else if (!self.reverseToLoop and shouldReset) self.currentSprite = 0;

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

pub const AnimationSpriteSheet = struct {
    const This = @This();
    spriteSheet: SpriteSheet,
    delay: Delay,
    count: usize,
    reverseToLoop: bool,
    onReverse: bool,

    pub fn init(filepath: [:0]const u8, spriteSize: [2]usize, grid: [2]usize, padding: utils.Point, reverseToLoop: bool) This {
        const spriteSheet = SpriteSheet.load_sprite_sheet(filepath, spriteSize[0], spriteSize[1], grid[0], grid[1], padding);

        return This{
            .spriteSheet = spriteSheet,
            .delay = Delay.new(500, true),
            .count = 0,
            .reverseToLoop = reverseToLoop,
            .onReverse = false,
        };
    }

    pub fn deinit(self: *This) void {
        self.spriteSheet.unload_sprite_sheet();
    }

    pub fn nextSprite(self: *This) void {
        if (self.delay.onCooldown()) return;

        if (self.onReverse) {
            self.applyReverse();
        } else {
            self.count += 1;
        }

        const shouldReset = self.count >= (self.spriteSheet.gridRows * self.spriteSheet.gridCols);
        const shouldReverse = !self.onReverse and shouldReset;
        if (self.reverseToLoop and shouldReverse) {
            self.onReverse = true;
            self.count -= 1;
        } else if (!self.reverseToLoop and shouldReset) self.count = 0;

        self.delay.applyDelay();
    }

    fn applyReverse(self: *This) void {
        if (self.count != 0) {
            self.count -= 1;
            return;
        }

        self.count = 0;
        self.onReverse = false;
    }

    pub fn draw(self: *const This, render: *const Render, position: utils.Point) void {
        const row = self.count / self.spriteSheet.gridRows;
        const col = self.count / self.spriteSheet.gridCols;

        render.drawSpriteSheet(position, self.spriteSheet, row, col);
    }
};
