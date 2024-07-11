const std = @import("std");
const expect = std.testing.expect;

const statusImport = @import("status.zig");
const Status = statusImport.Status;

const entityImport = @import("entity.zig");
const Entity = entityImport.Entity;

fn checkEntities(e1: Entity, e2: Entity) !void {
    try expect(e1.status.isEqual(e2.status));
    try expect(e1.defaultStatus.isEqual(e2.defaultStatus));
}

test "Should copy an entity" {
    const originalEntity = Entity{
        .status = Status{
            .health = 42,
            .attack = 2,
            .range = 4,
        },
        .defaultStatus = Status{
            .health = 4200,
            .attack = 20,
            .range = 40,
        },
    };

    var someEntity: Entity = undefined;
    someEntity.copy(originalEntity);

    try checkEntities(originalEntity, someEntity);
}

test "Should return health percentage" {
    const halfedEntity = Entity{ .status = Status{
        .health = 5,
        .attack = 4,
        .range = 2,
    }, .defaultStatus = Status{
        .health = 10,
        .attack = 4,
        .range = 2,
    } };

    const lifePercentage = halfedEntity.healthPercentage();

    try expect(lifePercentage == 0.5);
}
