const GridItemEnum = enum(i3) {
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
};
