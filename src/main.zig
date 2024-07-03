const std = @import("std");
const allocator = std.heap.page_allocator;

const utils = @import("utils/utils.zig");

const Entity = @import("core/entity.zig").Entity;

const grid = @import("core/grid.zig");
const Grid = grid.Grid;
const GridItemEnum = grid.GridItemEnum;
const GridItem = grid.GridItem;

const turret = @import("core/turret.zig");
const enemy = @import("core/enemy.zig");

const Render = @import("render/render.zig").Render;

const input = @import("input/input.zig");
const Input = input.Input;
const KeyEnum = input.KeyEnum;

pub fn main() !void {
    var g = try Grid.init(5, 5);
    defer g.deinit();

    // std.debug.print("\nFresh grid:\n", .{});
    // for (g.items.items, 0..) |item, i| {
    //     const str = switch (item) {
    //         .turret => "turret",
    //         .enemy => "enemy",
    //         .empty => "empty",
    //     };
    //     std.debug.print("\t[{d}]: {s}\n", .{ i, str });
    // }

    // TODO: Move entity position to grid
    var t = try allocator.create(turret.Turret);
    t.copy(turret.Turret.new(utils.Rectangle{
        .x = 400,
        .y = 300,
        .w = 32,
        .h = 64,
    }));

    var e = try allocator.create(enemy.Enemy);
    e.copy(enemy.Enemy.init(utils.Rectangle{
        .x = 200,
        .y = 300,
        .w = 32,
        .h = 64,
    }));
    defer e.deinit();
    try g.addItem(1, 1, .enemy, @as(*anyopaque, @ptrCast(e)));
    try g.addItem(2, 1, .turret, @as(*anyopaque, @ptrCast(t)));

    // std.debug.print("Final grid:\n", .{});
    // for (g.items.items, 0..) |item, i| {
    //     switch (item) {
    //         .turret => std.debug.print("\t[{d}]: turret\n", .{i}),
    //         .enemy => std.debug.print("\t[{d}]: enemy\n", .{i}),
    //         .empty => {},
    //     }
    // }

    try e.addObserver(t);

    e.notifyAll();

    const stdout = std.io.getStdOut().writer();
    try stdout.writeAll("Hello world!\n");

    var render = Render.init();
    defer render.deinit();

    var rect = utils.Rectangle{
        .x = 42,
        .y = 42,
        .w = 128,
        .h = 128,
    };
    const color = utils.Color{
        .r = 0x19,
        .g = 0x19,
        .b = 0xff,
        .a = 0xff,
    };

    // NOTE: For health example
    const baseRect: utils.Rectangle = .{
        .x = 500,
        .y = 500,
        .w = 400,
        .h = 100,
    };
    const baseColor = utils.Color{
        .r = 0xaa,
        .g = 0xaa,
        .b = 0xaa,
        .a = 0xff,
    };
    const healthColor = utils.Color{
        .r = 0xff,
        .g = 0x00,
        .b = 0x00,
        .a = 0xff,
    };

    while (render.shouldRender()) {
        render.beginDraw();
        defer render.endDraw();

        render.drawRectangleRect(rect, color);

        displayHealth(render, baseRect, baseColor, healthColor, 0.32);

        // render.drawRectangleRect(e.entity.box, enemy.DEFAULT_COLOR);

        // render.drawRectangleRect(t.entity.box, turret.DEFAULT_COLOR);
        // const turretRect = t.entity.getHealthRect();
        // const turretHpP: f32 = t.entity.healthPercentage();
        // displayHealth(render, turretRect, baseColor, healthColor, turretHpP);

        const speed = rect.w;
        var ySpeed: f32 = 0;
        var xSpeed: f32 = 0;

        if (Input.isKeyDown(.Up)) {
            ySpeed -= speed;
        }
        if (Input.isKeyDown(.Down)) {
            ySpeed += speed;
        }
        if (Input.isKeyDown(.Left)) {
            xSpeed -= speed;
        }
        if (Input.isKeyDown(.Right)) {
            xSpeed += speed;
        }

        for (g.items.items) |item| {
            // std.debug.print("Enum: {d} {any}\n", .{ i, item });
            switch (item) {
                .turret => |gridTurret| {
                    drawTurret(render, gridTurret, baseColor);
                },
                .enemy => |gridEnemy| {
                    drawEnemy(render, gridEnemy, baseColor);
                },
                .empty => {},
            }
        }

        const gridOffset = utils.Point{ .x = 64, .y = 64 };
        const cellSize = 128;
        drawGrid(render, g, gridOffset, cellSize);

        const frameTime = render.getFrameTime();
        rect.x += xSpeed * frameTime;
        rect.y += ySpeed * frameTime;
        e.move(frameTime);

        if (Input.isMouseBntPressed(input.MouseBntEnum.Left)) {
            const mousePoint = Input.getMousePoint();
            std.debug.print("Mouse point: {any}\n", .{mousePoint});

            if (g.worldToGrid(mousePoint, gridOffset, cellSize)) |p| {
                std.debug.print("Grid point: {any}\n", .{p});

                const box = utils.Rectangle{
                    .x = (p.x + 1) * cellSize - 16,
                    .y = (p.y + 1) * cellSize - 24,
                    .w = 32,
                    .h = 64,
                };
                // Maybe move to heap
                // var tn = turret.Turret.new(box);
                var tn_ptr = try allocator.create(turret.Turret);
                tn_ptr.copy(turret.Turret.new(box));

                try g.addItem(@as(usize, @intFromFloat(p.x)), @as(usize, @intFromFloat(p.y)), GridItemEnum.turret, @as(*anyopaque, @ptrCast(tn_ptr)));

                // TODO: Check how the array is updated
                std.debug.print("Grid items len: {d}\n", .{g.items.items.len});
                std.debug.print("Grid items: {any}\n", .{g.items.items});
            }
        }
    }
}

fn displayHealth(render: Render, baseRect: utils.Rectangle, baseColor: utils.Color, healthColor: utils.Color, percentage: f32) void {
    var healthRect = baseRect.clone();
    healthRect.w = baseRect.w * percentage;

    render.drawRectangleRect(baseRect, baseColor);
    healthRect.x += baseRect.w - healthRect.w;
    render.drawRectangleRect(healthRect, healthColor);
}

fn drawTurret(render: Render, t: *const turret.Turret, baseColor: utils.Color) void {
    render.drawRectangleRect(t.entity.box, turret.DEFAULT_COLOR);

    const turretRect = t.entity.getHealthRect();
    const turretHpP: f32 = t.entity.healthPercentage();
    const healthColor = utils.Color{ .r = 255, .g = 0, .b = 0, .a = 255 };

    displayHealth(render, turretRect, baseColor, healthColor, turretHpP);
}

fn drawEnemy(render: Render, e: *const enemy.Enemy, baseColor: utils.Color) void {
    render.drawRectangleRect(e.entity.box, enemy.DEFAULT_COLOR);

    const enemyRect = e.entity.getHealthRect();
    const enemyHpP: f32 = e.entity.healthPercentage();
    const healthColor = utils.Color{ .r = 255, .g = 0, .b = 0, .a = 255 };

    displayHealth(render, enemyRect, baseColor, healthColor, enemyHpP);
}

fn drawGrid(render: Render, g: Grid, offset: utils.Point, gridSize: f32) void {
    const worldWidth: f32 = offset.x + @as(f32, @floatFromInt(g.width)) * gridSize;
    const worldHeight: f32 = offset.y + @as(f32, @floatFromInt(g.height)) * gridSize;
    const lineColor = utils.Color{ .r = 0xff, .g = 0xff, .b = 0xff, .a = 0xff };

    var i: usize = 0;

    var p1 = utils.Point{ .x = offset.x, .y = offset.y };
    var p2 = utils.Point{ .x = worldWidth, .y = offset.y };
    while (i < g.height + 1) : (i += 1) {
        render.drawLineP(p1, p2, lineColor);
        p1.y += gridSize;
        p2.y += gridSize;
    }

    i = 0;

    p1 = utils.Point{ .x = offset.x, .y = offset.y };
    p2 = utils.Point{ .x = offset.x, .y = worldHeight };
    while (i < g.width + 1) : (i += 1) {
        render.drawLineP(p1, p2, lineColor);
        p1.x += gridSize;
        p2.x += gridSize;
    }
}
