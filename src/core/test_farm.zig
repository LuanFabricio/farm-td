const std = @import("std");
const expect = std.testing.expect;
const Allocator = std.heap.page_allocator;

const farmImport = @import("farm.zig");
const Farm = farmImport.Farm;

test "Should get gold and update the timer" {
    const goldGain = 42;
    var farmItem = try Farm.init(10, goldGain, 1200);
    defer Allocator.destroy(farmItem);
    const oldTime = farmItem.goldTime;

    const gold = farmItem.getGold();
    try expect(gold != null);
    try expect(gold.? == goldGain);

    try expect(oldTime < farmItem.goldTime);

    const nullGold = farmItem.getGold();
    try expect(nullGold == null);
}
