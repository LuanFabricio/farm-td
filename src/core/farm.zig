const std = @import("std");
const timestamp = std.time.timestamp;

pub const Farm = struct {
    const This = @This();
    cost: u32,
    gain: u32,
    delay: i64,
    goldTime: i64,

    pub fn new(cost: u32, gain: u32, delay: i64) This {
        const now = timestamp();
        return This{
            .cost = cost,
            .gain = gain,
            .delay = delay,
            .goldTime = now,
        };
    }

    pub fn getGold(self: *This) ?u32 {
        const now = timestamp();
        if (now < self.goldTime) return null;

        self.goldTime = now + self.delay;
        return self.gain;
    }
};
