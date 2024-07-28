const std = @import("std");
const timestamp = std.time.milliTimestamp;

pub const Delay = struct {
    const This = @This();
    delay: i64,
    timer: i64,

    pub fn new(delay: i64, startOnCooldown: bool) This {
        const now = timestamp();
        return This{
            .delay = delay,
            .timer = now + if (startOnCooldown) delay else 0,
        };
    }

    pub fn onCooldown(self: *const This) bool {
        const now = timestamp();
        return self.timer > now;
    }

    pub fn applyDelay(self: *This) void {
        const now = timestamp();
        self.timer = now + self.delay;
    }
};
