const std = @import("std");
const rl = @import("raylib");
const Widget = @import("widget.zig").Widget;
const Button = @import("widget.zig").Button;
const Callback = @import("root.zig").Callback;
const U8StringZ = @import("root.zig").U8StringZ;

const MainMenuScene = @import("scenes/MainMenuScene.zig");
const OptionsScene = @import("scenes/OptionsScene.zig");
const GameplaySetupScene = @import("scenes/GameplaySetupScene.zig");
const PongScene = @import("scenes/PongScene.zig");
// Agregar más escenas según sea necesario

const AppState = @import("app_state.zig").AppState;
const pong_bg_color = @import("widget.zig").pong_bg_color;

pub const SceneTag = enum {
    MainMenu,
    Options,
    GameplaySetup,
    Pong,
    // Agregar más escenas según sea necesario
};

pub const Scene = union(SceneTag) {
    MainMenu: MainMenuScene,
    Options: OptionsScene,
    GameplaySetup: GameplaySetupScene,
    Pong: PongScene,
    // Agregar más escenas según sea necesario

    pub fn init(allocator: std.mem.Allocator, tag: SceneTag, options: struct {
        background_color: rl.Color = pong_bg_color,
    }) !Scene {
        return switch (tag) {
            .MainMenu => .{ .MainMenu = try MainMenuScene.init(allocator, .{
                .background_color = options.background_color,
            }) },
            .Options => .{ .Options = try OptionsScene.init(allocator, .{
                .background_color = options.background_color,
            }) },
            .GameplaySetup => .{ .GameplaySetup = try GameplaySetupScene.init(allocator, .{
                .background_color = options.background_color,
            }) },
            .Pong => .{ .Pong = try PongScene.init(allocator, .{
                .background_color = options.background_color,
            }) },
        };
    }

    // ===== Métodos de la Scene =====

    pub fn update(self: *Scene) void {
        return switch (self.*) {
            .MainMenu => |*scene| scene.update(),
            .Options => |*scene| scene.update(),
            .GameplaySetup => |*scene| scene.update(),
            .Pong => |*scene| scene.update(),
        };
    }

    pub fn draw(self: *const Scene) void {
        switch (self.*) {
            .MainMenu => |*scene| scene.draw(),
            .Options => |*scene| scene.draw(),
            .GameplaySetup => |*scene| scene.draw(),
            .Pong => |*scene| scene.draw(),
        }

        // Show FPS:
        if (AppState.getInstance().config.options.display_fps) {
            var buf: [32]u8 = undefined;
            const fps = rl.getFPS();
            const fps_text = std.fmt.bufPrintZ(&buf, "FPS: {d}", .{fps}) catch "FPS: ??";
            rl.drawText(fps_text, 10, 10, 20, .white);
        }
    }

    pub fn deinit(self: *Scene, allocator: std.mem.Allocator) void {
        switch (self.*) {
            .MainMenu => |*scene| scene.deinit(allocator),
            .Options => |*scene| scene.deinit(allocator),
            .GameplaySetup => |*scene| scene.deinit(allocator),
            .Pong => |*scene| scene.deinit(allocator),
        }
    }
};
