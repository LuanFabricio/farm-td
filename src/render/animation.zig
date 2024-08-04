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

const AnimationState = struct {
    const This = @This();

    currentSprite: usize,
    delay: Delay,
    reverseToLoop: bool,
    onReverse: bool,
    maxSprites: usize,

    fn new(delay: Delay, reverseToLoop: bool) This {
        return This{
            .maxSprites = 0,
            .currentSprite = 0,
            .delay = delay,
            .reverseToLoop = reverseToLoop,
            .onReverse = false,
        };
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

fn _Animation(
    value_type: type,
    initFnType: type,
    initSpritesFn: initFnType,
    deinitFn: fn (sprites: *value_type) void,
    maxSpritesFn: fn (sprites: value_type) usize,
) type {
    return struct {
        const This = @This();
        pub const initSprites: initFnType = initSpritesFn;

        sprites: value_type,
        animationState: AnimationState,
        // init: initFnType,

        pub fn init(
            sprites: value_type,
            delay: Delay,
            reverseToLoop: bool,
        ) This {
            // const sprites = initFn(filename, spriteSize, gridSize, spritePadding);
            var animationState = AnimationState.new(delay, reverseToLoop);
            animationState.maxSprites = maxSpritesFn(sprites);
            return This{
                .sprites = sprites,
                .animationState = animationState,
            };
        }

        pub fn deinit(self: *This) void {
            deinitFn(&self.sprites);
        }
    };
}

fn _initAnimationSpritesheet(filename: [:0]const u8, sprtSize: [2]usize, gridSize: [2]usize, sprtPadding: utils.Point) SpriteSheet {
    return SpriteSheet.load_sprite_sheet(filename, sprtSize[0], sprtSize[1], gridSize[0], gridSize[1], sprtPadding);
}

fn _deinitAnimationSpritesheet(sprites: *SpriteSheet) void {
    sprites.unload_sprite_sheet();
}

fn _maxSpritesFnSpritesheet(sprites: SpriteSheet) usize {
    return sprites.gridRows * sprites.gridCols;
}

pub const AnimationSpritesheet = _Animation(
    SpriteSheet,
    @TypeOf(_initAnimationSpritesheet),
    _initAnimationSpritesheet,
    _deinitAnimationSpritesheet,
    _maxSpritesFnSpritesheet,
);

fn _initAnimationSprites(filename: [:0]const u8, nSprites: usize) ArrayList(Sprite) {
    var sprites = ArrayList(Sprite).init(Allocator);

    // Only uses first item
    for (1..(nSprites + 1)) |idx| {
        const file = std.fmt.allocPrintZ(Allocator, "{s}{d}.png", .{ filename, idx }) catch unreachable;
        defer Allocator.free(file);

        sprites.append(Sprite.load_texture(file)) catch unreachable;
    }

    return sprites;
}

fn _deinitAnimationSprites(sprites: *ArrayList(Sprite)) void {
    for (sprites.items) |*sprt| {
        sprt.unload_texture();
    }
    sprites.deinit();
}

fn _maxSpritesFnSprites(sprites: ArrayList(Sprite)) usize {
    return sprites.items.len;
}

pub const AnimationSprites = _Animation(
    ArrayList(Sprite),
    @TypeOf(_initAnimationSprites),
    _initAnimationSprites,
    _deinitAnimationSprites,
    _maxSpritesFnSprites,
);

// pub const Animation = struct {
//     const This = @This();
//     sprites: ArrayList(Sprite),
//     currentSprite: usize,
//     delay: Delay,
//     reverseToLoop: bool,
//     onReverse: bool,
//
//     pub fn init(filepath: []const u8, frames: usize, reverseToLoop: bool) !This {
//         var sprites = ArrayList(Sprite).init(Allocator);
//
//         for (1..(frames + 1)) |idx| {
//             const file = try std.fmt.allocPrintZ(Allocator, "{s}{d}.png", .{ filepath, idx });
//             defer Allocator.free(file);
//             try sprites.append(Sprite.load_texture(file));
//         }
//
//         return This{
//             .sprites = sprites,
//             .currentSprite = 0,
//             .delay = Delay.new(500, true),
//             .reverseToLoop = reverseToLoop,
//             .onReverse = false,
//         };
//     }
//
//     pub fn deinit(self: *const This) void {
//         for (self.sprites.items) |sprite| {
//             sprite.unload_texture();
//         }
//         self.sprites.deinit();
//     }
//
//     pub fn nextSprite(self: *This) void {
//         if (self.delay.onCooldown()) return;
//
//         if (self.onReverse) {
//             self.applyReverse();
//         } else {
//             self.currentSprite += 1;
//         }
//
//         const shouldReset = self.currentSprite >= self.sprites.items.len;
//         const shouldReverse = !self.onReverse and shouldReset;
//         if (self.reverseToLoop and shouldReverse) {
//             self.onReverse = true;
//             self.currentSprite -= 1;
//         } else if (!self.reverseToLoop and shouldReset) self.currentSprite = 0;
//
//         self.delay.applyDelay();
//     }
//
//     fn applyReverse(self: *This) void {
//         if (self.currentSprite != 0) {
//             self.currentSprite -= 1;
//             return;
//         }
//         self.currentSprite = 0;
//         self.onReverse = false;
//     }
// };
//
// pub const AnimationSpriteSheet = struct {
//     const This = @This();
//     spriteSheet: SpriteSheet,
//     delay: Delay,
//     count: usize,
//     reverseToLoop: bool,
//     onReverse: bool,
//
//     pub fn init(filepath: [:0]const u8, spriteSize: [2]usize, grid: [2]usize, padding: utils.Point, reverseToLoop: bool) This {
//         const spriteSheet = SpriteSheet.load_sprite_sheet(filepath, spriteSize[0], spriteSize[1], grid[0], grid[1], padding);
//
//         return This{
//             .spriteSheet = spriteSheet,
//             .delay = Delay.new(500, true),
//             .count = 0,
//             .reverseToLoop = reverseToLoop,
//             .onReverse = false,
//         };
//     }
//
//     pub fn deinit(self: *This) void {
//         self.spriteSheet.unload_sprite_sheet();
//     }
//
//     pub fn nextSprite(self: *This) void {
//         if (self.delay.onCooldown()) return;
//
//         if (self.onReverse) {
//             self.applyReverse();
//         } else {
//             self.count += 1;
//         }
//
//         const shouldReset = self.count >= (self.spriteSheet.gridRows * self.spriteSheet.gridCols);
//         const shouldReverse = !self.onReverse and shouldReset;
//         if (self.reverseToLoop and shouldReverse) {
//             self.onReverse = true;
//             self.count -= 1;
//         } else if (!self.reverseToLoop and shouldReset) self.count = 0;
//
//         self.delay.applyDelay();
//     }
//
//     fn applyReverse(self: *This) void {
//         if (self.count != 0) {
//             self.count -= 1;
//             return;
//         }
//
//         self.count = 0;
//         self.onReverse = false;
//     }
//
//     pub fn draw(self: *const This, render: *const Render, position: utils.Point) void {
//         const row = self.count / self.spriteSheet.gridRows;
//         const col = self.count / self.spriteSheet.gridCols;
//
//         render.drawSpriteSheet(position, self.spriteSheet, row, col);
//     }
// };
