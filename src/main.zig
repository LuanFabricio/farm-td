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

const farmImport = @import("core/farm.zig");
const Farm = farmImport.Farm;

const Render = @import("render/render.zig").Render;
// const spriteImport = @import("render/sprite.zig");
const spriteImport = @import("render/sprite.zig");
const Sprite = spriteImport.Sprite;
const SpriteSheet = spriteImport.SpriteSheet;

const animationImport = @import("render/animation.zig");
const AnimationSpritesheet = animationImport.AnimationSpritesheet;
const AnimationSprites = animationImport.AnimationSprites;
const AnimationColor = animationImport.AnimationColor;

const Delay = @import("utils/delay.zig").Delay;

const input = @import("input/input.zig");
const Input = input.Input;
const KeyEnum = input.KeyEnum;

const gameImport = @import("core/game.zig");
const Game = gameImport.Game;
const TurretGrid = gameImport.TurretGrid;
const FarmGrid = gameImport.FarmGrid;

const SCREEN_WIDTH: usize = 1280;
const SCREEN_HEIGHT: usize = 720;

const gridSize = 96;
const turretGridOffset = utils.Point{ .x = @as(f32, @floatFromInt(gridSize)) / 2 + gridSize / 2, .y = gridSize };
const farmGridOffset = utils.Point{ .x = 1280 - @as(f32, @floatFromInt(gridSize)) * 5 + gridSize / 2, .y = gridSize };
const farmBuyGridOffset = utils.Point{ .x = 1280 - @as(f32, @floatFromInt(gridSize)) * 2 + gridSize / 2, .y = gridSize };
const turretBuyGridOffset = utils.Point{ .x = 1280 - @as(f32, @floatFromInt(gridSize)) * 2 + gridSize / 2, .y = gridSize * 3 };

const TestSprts = struct {
    testCustomSh1: AnimationSpritesheet,
    testCustomSh2: AnimationSprites,
    testColors: AnimationColor,
};

pub fn main() !void {
    var game = try Game.init(300, 7, 5, 2, 4, 1, 2);
    defer game.deinit();

    // delay = Delay.new(500, true);

    game.farmGrid.addItem(0, 0, try Farm.init(32, 1600, 15));

    game.farmBuyGrid.addItem(0, 0, try Farm.init(32, 1600, 10));
    game.turretBuyGrid.addItem(0, 0, try turret.Turret.init());

    game.cursorTurret = try turret.Turret.init();
    _ = try game.addTurret(game.turretGrid.width - 1, 2);
    game.cursorTurret = null;

    const spawnerBase = utils.Rectangle{
        .x = 0,
        .y = turretGridOffset.y + 32,
        .w = 32,
        .h = 64,
    };

    for (3..game.turretGrid.height) |i| {
        var spawnerBox: utils.Rectangle = undefined;
        spawnerBox.copy(spawnerBase);
        spawnerBox.y += @as(f32, @floatFromInt(i)) * gridSize;

        try game.addEnemySpawn(enemy.EnemySpawner.new(30, spawnerBox));
    }

    const stdout = std.io.getStdOut().writer();
    try stdout.writeAll("Hello world!\n");

    var render = Render.init(SCREEN_WIDTH, SCREEN_HEIGHT);
    defer render.deinit();

    const testColors = [_]utils.Color{
        utils.Color{ .r = 0xff, .g = 0xff, .b = 0xff, .a = 0xff },
        utils.Color{ .r = 0xfa, .g = 0xfa, .b = 0xfa, .a = 0xff },
        utils.Color{ .r = 0xf0, .g = 0xf0, .b = 0xf0, .a = 0xff },
        utils.Color{ .r = 0xef, .g = 0xef, .b = 0xef, .a = 0xff },
        utils.Color{ .r = 0xea, .g = 0xea, .b = 0xea, .a = 0xff },
        utils.Color{ .r = 0xe0, .g = 0xe0, .b = 0xe0, .a = 0xff },
        utils.Color{ .r = 0xdf, .g = 0xdf, .b = 0xdf, .a = 0xff },
        utils.Color{ .r = 0xda, .g = 0xda, .b = 0xda, .a = 0xff },
        utils.Color{ .r = 0xd0, .g = 0xd0, .b = 0xd0, .a = 0xff },
        utils.Color{ .r = 0xcf, .g = 0xcf, .b = 0xcf, .a = 0xff },
        utils.Color{ .r = 0xca, .g = 0xca, .b = 0xca, .a = 0xff },
        utils.Color{ .r = 0xc0, .g = 0xc0, .b = 0xc0, .a = 0xff },
        utils.Color{ .r = 0xbf, .g = 0xbf, .b = 0xbf, .a = 0xff },
        utils.Color{ .r = 0xba, .g = 0xba, .b = 0xba, .a = 0xff },
        utils.Color{ .r = 0xb0, .g = 0xb0, .b = 0xb0, .a = 0xff },
        utils.Color{ .r = 0xaf, .g = 0xaf, .b = 0xaf, .a = 0xff },
        utils.Color{ .r = 0xaa, .g = 0xaa, .b = 0xaa, .a = 0xff },
        utils.Color{ .r = 0xa0, .g = 0xa0, .b = 0xa0, .a = 0xff },
    };
    // TODO: Remove testSpr
    var testSprts = TestSprts{
        .testCustomSh1 = AnimationSpritesheet.init(
            AnimationSpritesheet.initSprites("assets/sprites/testsheet/testsheet-Sheet.png", [2]usize{ 32, 32 }, [2]usize{ 3, 1 }, utils.Point{ .x = 0, .y = 0 }),
            Delay.new(125, true),
            false,
        ),
        .testCustomSh2 = AnimationSprites.init(
            AnimationSprites.initSprites("assets/sprites/test/test", 5),
            Delay.new(550, true),
            true,
        ),
        .testColors = AnimationColor.init(AnimationColor.initSprites(testColors.len, &testColors), Delay.new(500, true), true),
    };
    defer testSprts.testCustomSh1.deinit();
    defer testSprts.testCustomSh2.deinit();
    defer testSprts.testColors.deinit();

    while (render.shouldRender()) {
        // TODO: Remove testSpr
        drawScene(render, &game, &testSprts);
        updateScene(render, &game) catch |err| std.debug.print("Update error: {any}\n", .{err});
        try drawUI(render, &game);

        game.farmGold();
    }
}

fn drawScene(render: Render, game: *const Game, testSprts: *TestSprts) void {
    const baseColor = utils.Color{
        .r = 0xaa,
        .g = 0xaa,
        .b = 0xaa,
        .a = 0xff,
    };

    render.beginDraw();
    defer render.endDraw();

    for (game.enemies.items) |currentEnemy| {
        drawEnemy(render, currentEnemy, baseColor);
    }

    for (game.turretGrid.getItems(), 0..) |currentItem, idx| {
        if (currentItem) |currentTurret| {
            const turretPoint = game.turretGrid.indexToXY(idx);
            const center = game.turretGrid.gridToWorld(turretPoint, turretGridOffset, gridSize);

            drawGridItem(render, center, turret.DEFAULT_COLOR, turret.TURRET_SIZE);

            const turretHealthRect = getHealthRect(getItemRect(center));
            const turretHpP: f32 = currentTurret.entity.healthPercentage();
            const healthColor = utils.Color{ .r = 255, .g = 0, .b = 0, .a = 255 };

            displayHealth(render, turretHealthRect, baseColor, healthColor, turretHpP);
        }
    }

    const farmColor = utils.Color{ .r = 0xff, .g = 0xff, .b = 0x00, .a = 0xff };
    const farmItems = game.farmGrid.getItems();
    for (farmItems, 0..) |item, idx| {
        if (item) |_| {
            const farmPoint = game.farmGrid.indexToXY(idx);
            const center = game.farmGrid.gridToWorld(farmPoint, farmGridOffset, gridSize);

            drawGridItem(render, center, farmColor, farmImport.FARM_SIZE);
        }
    }

    for (game.farmBuyGrid.getItems(), 0..) |item, idx| {
        if (item) |_| {
            const farmBuyPoint = game.farmBuyGrid.indexToXY(idx);
            const center = game.farmBuyGrid.gridToWorld(farmBuyPoint, farmBuyGridOffset, gridSize);

            drawGridItem(render, center, farmColor, farmImport.FARM_SIZE);
        }
    }

    for (game.turretBuyGrid.getItems(), 0..) |item, idx| {
        if (item) |_| {
            const turretBuyPoint = game.turretBuyGrid.indexToXY(idx);
            const center = game.turretBuyGrid.gridToWorld(turretBuyPoint, turretBuyGridOffset, gridSize);

            drawGridItem(render, center, turret.DEFAULT_COLOR, turret.TURRET_SIZE);
        }
    }

    drawGrid(render, game.turretGrid.width, game.turretGrid.height, turretGridOffset);
    drawGrid(render, game.farmGrid.width, game.farmGrid.height, farmGridOffset);
    drawGrid(render, game.farmBuyGrid.width, game.farmBuyGrid.height, farmBuyGridOffset);
    drawGrid(render, game.turretBuyGrid.width, game.turretBuyGrid.height, turretBuyGridOffset);

    const texColor = utils.Color{
        .r = 0xff,
        .g = 0xff,
        .b = 0xff,
        .a = 0xff,
    };
    // utils.Raylib.DrawTexture(testSprts.testSprite.content, 400, 400, texColor.toRayColor());
    // utils.Raylib.DrawTexture(testSprts.testAnimation1.sprites.items[testSprts.testAnimation1.currentSprite].content, 500, 500, texColor.toRayColor());
    // testSprts.testAnimation1.nextSprite();

    // utils.Raylib.DrawTexture(testSprts.testAnimation2.sprites.items[testSprts.testAnimation2.currentSprite].content, 536, 500, texColor.toRayColor());
    // testSprts.testAnimation2.nextSprite();

    // testSprts.testSpritesheetAnimation1.draw(&render, utils.Point{ .x = 136, .y = 100 });
    // testSprts.testSpritesheetAnimation1.nextSprite();

    // testSprts.testSpritesheetAnimation2.draw(&render, utils.Point{ .x = 172, .y = 100 });
    // testSprts.testSpritesheetAnimation2.nextSprite();

    const row1 = testSprts.testCustomSh1.animationState.currentSprite / testSprts.testCustomSh1.sprites.gridRows;
    const col1 = testSprts.testCustomSh1.animationState.currentSprite / testSprts.testCustomSh1.sprites.gridCols;
    render.drawSpriteSheet(utils.Point{ .x = 232, .y = 100 }, testSprts.testCustomSh1.sprites, row1, col1);
    testSprts.testCustomSh1.animationState.nextSprite();

    utils.Raylib.DrawTexture(testSprts.testCustomSh2.sprites.items[testSprts.testCustomSh2.animationState.currentSprite].content, 268, 100, texColor.toRayColor());
    testSprts.testCustomSh2.animationState.nextSprite();

    const colorIdx = testSprts.testColors.animationState.currentSprite;
    std.debug.print("Color: {any}\n", .{testSprts.testColors.sprites.items[colorIdx]});
    render.drawRectangle(400, 400, 512, 512, testSprts.testColors.sprites.items[colorIdx]);
    testSprts.testColors.animationState.nextSprite();
}

fn updateScene(render: Render, game: *Game) !void {
    if (Input.isMouseBntPressed(input.MouseBntEnum.Left)) {
        const mousePoint = Input.getMousePoint();
        // std.debug.print("Mouse point: {any}\n", .{mousePoint});

        if (game.turretGrid.worldToGrid(mousePoint, turretGridOffset, gridSize)) |p| {
            var newTurretPtr = try allocator.create(turret.Turret);
            newTurretPtr.copy(turret.Turret.new());

            const x: usize = @intFromFloat(p.x);
            const y: usize = @intFromFloat(p.y);
            _ = try game.addTurret(x, y);
        }

        if (game.farmGrid.worldToGrid(mousePoint, farmGridOffset, gridSize)) |p| {
            const x: usize = @intFromFloat(p.x);
            const y: usize = @intFromFloat(p.y);
            _ = try game.addFarm(x, y);
        }

        if (game.farmBuyGrid.worldToGrid(mousePoint, farmBuyGridOffset, gridSize)) |p| {
            const x: usize = @intFromFloat(p.x);
            const y: usize = @intFromFloat(p.y);
            game.updateCursorFarm(x, y);
        }

        if (game.turretBuyGrid.worldToGrid(mousePoint, turretBuyGridOffset, gridSize)) |p| {
            const x: usize = @intFromFloat(p.x);
            const y: usize = @intFromFloat(p.y);
            game.updateCursorTurret(x, y);
        }
    }

    try game.spawnEnemies();

    const frameTime = render.getFrameTime();
    // std.debug.print("Moving {d} enemys\n", .{game.enemies.items.len});
    for (game.enemies.items) |currentEnemy| {
        currentEnemy.move(frameTime);
    }

    try game.turretShoot(turretGridOffset, gridSize);
    // TODO(luan): Maybe move maxWidth to Game property
    game.cleanDeadEnemies(@as(f32, @floatFromInt(render.screenWidth)));

    try game.enemyAttack(turretGridOffset, gridSize);
    game.cleanDeadTurrets();
}

fn drawUI(render: Render, game: *const Game) !void {
    const goldText = try std.fmt.allocPrintZ(allocator, "Gold: {d}", .{game.gold});
    defer allocator.free(goldText);

    const position = utils.Point{
        .x = 50,
        .y = 50,
    };
    const color = utils.Color{
        .r = 0xff,
        .g = 0xff,
        .b = 0xff,
        .a = 0xff,
    };
    render.drawText(goldText, 32, position, color);
}

fn displayHealth(render: Render, baseRect: utils.Rectangle, baseColor: utils.Color, healthColor: utils.Color, percentage: f32) void {
    var healthRect = baseRect.clone();
    healthRect.w = baseRect.w * percentage;

    render.drawRectangleRect(baseRect, baseColor);
    healthRect.x += baseRect.w - healthRect.w;
    render.drawRectangleRect(healthRect, healthColor);
}

fn drawGridItem(render: Render, center: utils.Point, itemColor: utils.Color, itemSize: utils.Point) void {
    const itemRect = utils.Rectangle{
        .x = center.x + @as(f32, @floatFromInt(gridSize / 2)) - itemSize.x / 2,
        .y = center.y + itemSize.y / 2,
        .w = itemSize.x,
        .h = itemSize.y,
    };

    render.drawRectangleRect(itemRect, itemColor);
}

fn getItemRect(center: utils.Point) utils.Rectangle {
    return utils.Rectangle{
        .x = center.x + @as(f32, @floatFromInt(gridSize / 2)) - 16,
        .y = center.y + 32,
        .w = 32,
        .h = 64,
    };
}

fn drawEnemy(render: Render, e: *const enemy.Enemy, baseColor: utils.Color) void {
    render.drawRectangleRect(e.box, enemy.DEFAULT_COLOR);

    const enemyRect = getHealthRect(e.box);
    const enemyHpP: f32 = e.entity.healthPercentage();
    const healthColor = utils.Color{ .r = 255, .g = 0, .b = 0, .a = 255 };

    displayHealth(render, enemyRect, baseColor, healthColor, enemyHpP);

    // drawAttackRange
    // const enemyCenter = e.box.getCenter();
    // render.drawCircleLinesP(enemyCenter, e.entity.status.range, healthColor);
}

fn getHealthRect(rect: utils.Rectangle) utils.Rectangle {
    const center = rect.getCenter();
    var r = utils.Rectangle{
        .x = center.x,
        .y = center.y - rect.h / 2,
        .w = rect.w,
        .h = 10,
    };
    const yPadding = r.h + 5;

    r.x = center.x - r.w / 2;
    r.y -= yPadding;

    return r;
}

fn drawGrid(render: Render, width: usize, height: usize, offset: utils.Point) void {
    const worldWidth: f32 = offset.x + @as(f32, @floatFromInt(width)) * gridSize;
    const worldHeight: f32 = offset.y + @as(f32, @floatFromInt(height)) * gridSize;
    const lineColor = utils.Color{ .r = 0xff, .g = 0xff, .b = 0xff, .a = 0xff };

    var i: usize = 0;

    var p1 = utils.Point{ .x = offset.x, .y = offset.y };
    var p2 = utils.Point{ .x = worldWidth, .y = offset.y };
    while (i < height + 1) : (i += 1) {
        render.drawLineP(p1, p2, lineColor);
        p1.y += gridSize;
        p2.y += gridSize;
    }

    i = 0;

    p1 = utils.Point{ .x = offset.x, .y = offset.y };
    p2 = utils.Point{ .x = offset.x, .y = worldHeight };
    while (i < width + 1) : (i += 1) {
        render.drawLineP(p1, p2, lineColor);
        p1.x += gridSize;
        p2.x += gridSize;
    }
}
