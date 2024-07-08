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

const gameImport = @import("core/game.zig");
const Game = gameImport.Game;

pub fn main() !void {
    const gridOffset = utils.Point{ .x = 64, .y = 64 };
    const gridSize = 128;

    var game = try Game.init(5, 5);
    defer game.deinit();

    const turretPtr = try turret.Turret.init();
    // const enemyPtr = try enemy.Enemy.init(.{
    //     .x = 16,
    //     .y = 64 * 3 + 32,
    //     .w = 32,
    //     .h = 64,
    // });

    // try game.addEnemy(enemyPtr);
    try game.addTurret(4, 2, turretPtr);

    const spawnerBase = utils.Rectangle{
        .x = 0,
        .y = gridOffset.y + 32,
        .w = 32,
        .h = 64,
    };

    for (3..game.grid.height) |i| {
        var spawnerBox: utils.Rectangle = undefined;
        spawnerBox.copy(spawnerBase);
        spawnerBox.y += @as(f32, @floatFromInt(i)) * gridSize;

        try game.addEnemySpawn(enemy.EnemySpawner.new(180, spawnerBox));
    }

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
        try game.spawnEnemies();

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

        for (game.enemies.items) |currentEnemy| {
            drawEnemy(render, currentEnemy, baseColor);
        }

        for (game.grid.items.items, 0..) |currentItem, idx| {
            if (currentItem) |currentTurret| {
                const turretPoint = game.grid.indexToXY(idx);
                drawTurret(render, &game.grid, turretPoint, gridOffset, gridSize, currentTurret, baseColor);
            }
        }

        drawGrid(render, game.grid, gridOffset, gridSize);

        const frameTime = render.getFrameTime();
        rect.x += xSpeed * frameTime;
        rect.y += ySpeed * frameTime;

        for (game.enemies.items) |currentEnemy| {
            currentEnemy.move(frameTime);
        }

        if (Input.isMouseBntPressed(input.MouseBntEnum.Left)) {
            const mousePoint = Input.getMousePoint();
            // std.debug.print("Mouse point: {any}\n", .{mousePoint});

            if (game.grid.worldToGrid(mousePoint, gridOffset, gridSize)) |p| {
                var newTurretPtr = try allocator.create(turret.Turret);
                newTurretPtr.copy(turret.Turret.new());

                const x: usize = @intFromFloat(p.x);
                const y: usize = @intFromFloat(p.y);
                try game.addTurret(x, y, newTurretPtr);

                // TODO: Check how the array is updated
                std.debug.print("Grid items len: {d}\n", .{game.grid.items.items.len});
                for (game.grid.items.items, 0..) |item, idx| {
                    if (item) |item_ptr| {
                        std.debug.print("[{d}]Grid items: {any}\n", .{ idx, item_ptr });
                    }
                }
            }
        }
        try game.turretShoot(gridOffset, gridSize);
    }
}

fn displayHealth(render: Render, baseRect: utils.Rectangle, baseColor: utils.Color, healthColor: utils.Color, percentage: f32) void {
    var healthRect = baseRect.clone();
    healthRect.w = baseRect.w * percentage;

    render.drawRectangleRect(baseRect, baseColor);
    healthRect.x += baseRect.w - healthRect.w;
    render.drawRectangleRect(healthRect, healthColor);
}

fn drawTurret(render: Render, g: *const Grid, gridPoint: utils.Point, offset: utils.Point, gridSize: usize, t: *turret.Turret, baseColor: utils.Color) void {
    const turretCenter = g.gridToWorld(gridPoint, offset, gridSize);
    const turretRect = utils.Rectangle{
        .x = turretCenter.x + @as(f32, @floatFromInt(gridSize / 2)) - 16,
        .y = turretCenter.y + 32,
        .w = 32,
        .h = 64,
    };

    render.drawRectangleRect(turretRect, turret.DEFAULT_COLOR);

    const turretHealthRect = getHealthRect(turretRect);
    const turretHpP: f32 = t.entity.healthPercentage();
    const healthColor = utils.Color{ .r = 255, .g = 0, .b = 0, .a = 255 };

    displayHealth(render, turretHealthRect, baseColor, healthColor, turretHpP);
}

fn drawEnemy(render: Render, e: *const enemy.Enemy, baseColor: utils.Color) void {
    render.drawRectangleRect(e.box, enemy.DEFAULT_COLOR);

    const enemyRect = getHealthRect(e.box);
    const enemyHpP: f32 = e.entity.healthPercentage();
    const healthColor = utils.Color{ .r = 255, .g = 0, .b = 0, .a = 255 };

    displayHealth(render, enemyRect, baseColor, healthColor, enemyHpP);
}

fn getHealthRect(rect: utils.Rectangle) utils.Rectangle {
    const center = rect.getCenter();
    var r = utils.Rectangle{
        .x = center.x,
        .y = center.y,
        .w = rect.w,
        .h = 10,
    };
    const yPadding = r.h / 2 - 15;

    r.x = center.x - r.w / 2;
    r.y -= yPadding;

    return r;
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
