const std = @import("std");
const Allocator = std.heap.page_allocator;

const timestamp = std.time.timestamp;

const utils = @import("../utils/utils.zig");
const Delay = @import("../utils/delay.zig").Delay;

pub const FARM_SIZE = utils.Point{
    .x = 32,
    .y = 64,
};

pub const Farm = struct {
    const This = @This();
    cost: u32,
    gain: u32,
    // delay: i64,
    // goldTime: i64,
    delay: Delay,

    pub fn init(cost: u32, gain: u32, delay: i64) !*This {
        const farmPtr = try Allocator.create(This);
        farmPtr.cost = cost;
        farmPtr.gain = gain;
        farmPtr.delay = Delay.new(delay, true);

        return farmPtr;
    }

    pub fn heap_clone(self: *const This) !*This {
        return try This.init(self.cost, self.gain, self.delay.delay);
    }

    pub fn getGold(self: *This) ?u32 {
        if (self.delay.onCooldown()) return null;

        self.delay.applyDelay();
        return self.gain;
    }
};
