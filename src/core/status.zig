pub const Status = struct {
    health: i32,
    attack: i32,
    range: f32,

    pub fn copy(self: *Status, other: Status) void {
        self.health = other.health;
        self.attack = other.attack;
        self.range = other.range;
    }

    pub fn isEqual(self: *const Status, other: Status) bool {
        return self.health == other.health and self.attack == other.attack and self.range == other.range;
    }
};
