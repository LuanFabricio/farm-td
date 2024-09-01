const std = @import("std");
const expect = std.testing.expect;

const timestamp = std.time.milliTimestamp;
const utils = @import("../utils/utils.zig");

const entityImport = @import("entity.zig");
const Entity = entityImport.Entity;

const turretImport = @import("turret.zig");
const Turret = turretImport.Turret;

fn compareTurrets(t1: Turret, t2: Turret) !void {
    try expect(t1.entity.status.isEqual(t2.entity.status));
    try expect(t1.entity.defaultStatus.isEqual(t2.entity.defaultStatus));

    try expect(t1.delay.delay == t2.delay.delay);
    try expect(t1.delay.timer == t2.delay.timer);
}

test "Should copy the turret" {
    const t1 = Turret.new();

    var t2: Turret = undefined;
    t2.copy(t1);

    try compareTurrets(t1, t2);
}

test "Should attack if a point is on the attack range and not in cooldown" {
    var t1 = Turret.new();
    const tp = utils.Point{
        .x = 400,
        .y = 200,
    };

    const p1 = utils.Point{
        .x = 400,
        .y = 200,
    };
    try expect(t1.shouldAttack(tp, p1));

    const p2 = utils.Point{
        .x = 42,
        .y = 42,
    };
    try expect(!t1.shouldAttack(tp, p2));

    t1.delay.timer = timestamp() + t1.delay.delay * 10000;
    try expect(!t1.shouldAttack(tp, p1));
}

test "Should decrease enemy hp" {
    const turret = Turret.new();
    var e1 = Entity.defaultEnemy();

    turret.attackEntity(&e1);

    try expect(e1.status.health < e1.defaultStatus.health);
}

test "Should reset the attack delay" {
    var turret = Turret.new();

    const oldTimestamp = turret.delay.timer;
    turret.resetDelay();

    try expect(oldTimestamp < turret.delay.timer);
}
