const std = @import("std");

const entityImport = @import("core/entity.zig");
const Entity = entityImport.Entity;

pub fn main() !void {
    try Entity.defaultEnemy().save("assets/enemy.entity");
    const e = try Entity.load("assets/enemy.entity");
    std.debug.print("Entity: {any}\n", .{e});

    try Entity.defaultTurret().save("assets/turret.entity");
    const t = try Entity.load("assets/turret.entity");
    std.debug.print("Entity: {any}\n", .{t});
}
