const Turret = @import("turret.zig").Turret;
const Enemy = @import("enemy.zig").Enemy;

pub const GridItemEnum = enum(i3) {
    Empty,
    Turret,
    Enemy,
};

pub const GridItem = struct {
    data: ?*anyopaque,
    itemType: GridItemEnum,

    fn newEmpty() GridItem {
        return GridItem{
            .data = null,
            .itemType = GridItemEnum.Empty,
        };
    }

    fn newTurret(turret: *anyopaque) GridItem {
        return GridItem{
            .data = turret,
            .itemType = GridItemEnum.Turret,
        };
    }

    fn newEnemy(enemy: *anyopaque) GridItem {
        return GridItem{
            .data = enemy,
            .itemType = GridItemEnum.Enemy,
        };
    }
};

pub const Grid = struct {
    width: usize,
    height: usize,
    items: []GridItem,

    pub fn new(comptime width: usize, comptime height: usize) Grid {
        const len = width * height;
        return Grid{
            .width = width,
            .height = height,
            .items = &[_]GridItem{GridItem.newEmpty()} ** len,
        };
    }

    fn xyToIndex(self: *Grid, x: usize, y: usize) usize {
        return y * self.width + x;
    }

    pub fn addItem(self: *Grid, x: usize, y: usize, itemType: GridItemEnum, item: *anyopaque) void {
        const idx = self.xyToIndex(x, y);

        const gridItem = switch (itemType) {
            GridItemEnum.Turret => GridItem.newTurret(item),
            GridItemEnum.Enemy => GridItem.newEnemy(item),
            GridItemEnum.Empty => GridItem.newEmpty(),
        };

        self.items[idx] = gridItem;
    }

    pub fn getItem(self: *Grid, x: usize, y: usize) !GridItem {
        const idx = self.xyToIndex(x, y);

        if (idx > self.items.len) {
            return error{ItemOutOfBounds};
        }
        return self.items[idx];
    }

    pub fn castItemToTurret(item: GridItem) *Turret {
        return @ptrCast(@alignCast(item.data));
    }

    pub fn castItemToEnemy(item: GridItem) *Enemy {
        return @ptrCast(@alignCast(item.data));
    }
};
