const std = @import("std");
const expect = std.testing.expect;
const timestamp = std.time.milliTimestamp;

const delayImport = @import("delay.zig");
const Delay = delayImport.Delay;

test "It should start with timer equals now plus delay when stratOnCooldown is true" {
    const delay = 60 * 1000;
    const someDelay = Delay.new(delay, true);

    try expect(someDelay.delay == delay);
    const now = timestamp();
    try expect(someDelay.timer >= now);
}

test "It should start with timer equals now when stratOnCooldown is false" {
    const delay = 60 * 1000;
    const someDelay = Delay.new(delay, false);

    try expect(someDelay.delay == delay);
    const now = timestamp();
    try expect(someDelay.timer <= now);
}

test "onCooldown should be true if the timer is less or equal the now timestamp" {
    const delay = 60 * 1000;
    const someDelay = Delay.new(delay, false);

    try expect(!someDelay.onCooldown());
}

test "onCooldown should be false if the timer is greater than now timestamp" {
    const delay = 60 * 1000;
    const someDelay = Delay.new(delay, true);

    try expect(someDelay.onCooldown());
}

test "applyDelay should set timer propertie to be now plus delay" {
    const delay = 60 * 1000;
    var someDelay = Delay.new(delay, false);

    const now = timestamp();
    try expect(someDelay.timer <= now);

    someDelay.applyDelay();
    try expect(someDelay.timer > now);
}

test "applyDelayWithRand should use an range" {
    const delay = 60 * 1000;
    var delay1 = Delay.new(delay, false);

    const now1 = timestamp();
    try expect(delay1.timer <= now1);

    const range1 = [2]i64{ 10, 1000 };
    delay1.applyDelayWithRand(range1);
    try expect(delay1.timer > now1);

    var delay2 = Delay.new(delay, false);

    const now2 = timestamp();
    try expect(delay2.timer <= now2);

    const range2 = [2]i64{ -delay, -delay };
    delay2.applyDelayWithRand(range2);
    try expect(delay2.timer <= now2);
}
