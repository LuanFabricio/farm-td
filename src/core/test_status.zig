const std = @import("std");
const expect = std.testing.expect;

const statusImport = @import("status.zig");
const Status = statusImport.Status;

test "Should check if some status is equal to another" {
    const s1 = Status{
        .health = 1,
        .attack = 2,
        .range = 3,
    };
    const s2 = Status{
        .health = 2,
        .attack = 2,
        .range = 3,
    };
    try expect(!s1.isEqual(s2));

    const s3 = Status{
        .health = 1,
        .attack = 2,
        .range = 3,
    };
    try expect(s1.isEqual(s3));
}

test "Should copy another status" {
    const status = Status{
        .health = 1,
        .attack = 2,
        .range = 3,
    };

    var copy: Status = undefined;
    copy.copy(status);

    try expect(status.isEqual(copy));
}
