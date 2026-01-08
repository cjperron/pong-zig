const std = @import("std");

const rl = @import("raylib");

const pong_bg_color = @import("../widget.zig").pong_bg_color;

pub const GameplayScene = struct {
    pub fn init(allocator: std.mem.Allocator, options: struct {
        background_color: rl.Color = pong_bg_color,
    }) !GameplayScene {
        _ = allocator;
        _ = options;
        return GameplayScene{};
    }

    pub fn update(self: *GameplayScene) void {
        _ = self;
    }

    pub fn draw(self: *const GameplayScene) void {
        _ = self;
    }

    pub fn deinit(self: *GameplayScene, allocator: std.mem.Allocator) void {
        _ = self;
        _ = allocator;
    }
};
