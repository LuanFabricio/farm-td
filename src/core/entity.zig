const std = @import("std");
const allocator = std.heap.page_allocator;

const utils = @import("../utils/utils.zig");

const Status = @import("status.zig").Status;

pub const CacheEntity = struct {
    const This = @This();

    cache: std.AutoHashMap([]u8, Entity),

    pub fn init() This {
        return This{
            .cache = std.AutoHashMap([]u8, Entity).init(allocator),
        };
    }

    pub fn read(self: *This, file_path: []const u8) !Entity {
        if (self.cache.get(file_path)) |value| return value;

        const entity = try Entity.load(file_path);
        try self.cache.put(file_path, entity);
        return entity;
    }

    pub fn update(self: *This, file_path: []const u8, entity: Entity) !void {
        try self.cache.put(file_path, entity);
    }
};

pub const Entity = struct {
    const This = @This();
    cost: u32,
    defaultStatus: Status,
    status: Status,

    pub fn load(file_path: []const u8) !This {
        var buffer: [32]u8 = undefined;
        _ = try std.fs.cwd().readFile(file_path, &buffer);
        return @as(*This, @alignCast(@ptrCast(&buffer))).*;
    }

    pub fn save(self: *const This, file_path: []const u8) !void {
        const file = try std.fs.cwd().createFile(file_path, .{ .read = true });
        defer file.close();

        try file.writeAll(std.mem.asBytes(self));
    }

    pub fn copy(self: *This, other: This) void {
        self.cost = other.cost;
        self.status.copy(other.status);
        self.defaultStatus.copy(other.defaultStatus);
    }

    pub fn defaultTurret() This {
        const defaultStatus = Status{
            .health = 20,
            .attack = 4,
            .range = 350,
        };

        return This{
            .cost = 42,
            .status = defaultStatus,
            .defaultStatus = defaultStatus,
        };
    }

    pub fn defaultEnemy() This {
        const defaultStatus = Status{
            .health = 20,
            .attack = 5,
            .range = 10,
        };

        return This{
            .cost = 0,
            .status = defaultStatus,
            .defaultStatus = defaultStatus,
        };
    }

    pub fn healthPercentage(self: *const This) f32 {
        const currentHP: f32 = @floatFromInt(self.status.health);
        const defaultHP: f32 = @floatFromInt(self.defaultStatus.health);
        const percentage: f32 = currentHP / defaultHP;
        return percentage;
    }
};
