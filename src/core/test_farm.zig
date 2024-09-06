const std = @import("std");
const expect = std.testing.expect;
const timestamp = std.time.timestamp;
const Allocator = std.heap.page_allocator;

const farmImport = @import("farm.zig");
const Farm = farmImport.Farm;

test "Should start in cooldown" {
    const farmItem = try Farm.init(10, 10, 1200);
    defer Allocator.destroy(farmItem);

    const now = timestamp();
    try expect(now < farmItem.delay.timer);
}

test "Should get gold and update the goldTime with delay" {
    const goldGain = 42;
    const delay = 2;
    var farmItem = try Farm.init(10, goldGain, delay);
    defer Allocator.destroy(farmItem);
    // NOTE: Reseting the cooldown
    farmItem.delay.timer = timestamp();
    const oldTime = farmItem.delay.timer;

    const gold = farmItem.getGold();
    try expect(gold != null);
    try expect(gold.? == goldGain);

    try expect(oldTime < farmItem.delay.timer);

    const nullGold = farmItem.getGold();
    try expect(nullGold == null);
}

test "Should create a copy into heap" {
    const goldGain = 42;
    const delay = 2;

    const farmItem = try Farm.init(10, goldGain, delay);
    defer Allocator.destroy(farmItem);

    const heapCopyFarmItem = try farmItem.heap_clone();
    defer Allocator.destroy(heapCopyFarmItem);

    try expect(heapCopyFarmItem.delay.delay == farmItem.delay.delay);
    try expect(heapCopyFarmItem.delay.timer == farmItem.delay.timer);
    try expect(heapCopyFarmItem.cost == farmItem.cost);
    try expect(heapCopyFarmItem.gain == farmItem.gain);
}
