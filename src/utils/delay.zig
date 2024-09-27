const std = @import("std");
const timestamp = std.time.milliTimestamp;
const rand = std.crypto.random;

pub const Delay = struct {
    const This = @This();
    delay: i64,
    timer: i64,
    isRandom: bool,

    pub fn new(delay: i64, startOnCooldown: bool) This {
        const now = timestamp();
        return This{
            .delay = delay,
            .timer = now + if (startOnCooldown) delay else 0,
            .isRandom = false,
        };
    }

    pub fn onCooldown(self: *const This) bool {
        const now = timestamp();
        return self.timer > now;
    }

    pub fn applyDelay(self: *This) void {
        const now = timestamp();
        self.timer = now + self.delay;
        if (self.isRandom) {
            self.timer += rand.intRangeAtMost(i64, -2500, 150);
        }
    }
};
