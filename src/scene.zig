const std = @import("std");
const rl = @import("raylib");
const Widget = @import("widgets.zig").Widget;
const Button = @import("widgets.zig").Button;
const Callback = @import("root.zig").Callback;
const U8StringZ = @import("root.zig").U8StringZ;

const MainMenuScene = @import("scenes/main_menu.zig").MainMenuScene;
const OptionsScene = @import("scenes/options.zig").OptionsScene;
const GameplayScene = @import("scenes/gameplay.zig").GameplayScene;
// Agregar más escenas según sea necesario

const AppState = @import("app_state.zig").AppState;
const pong_bg_color = @import("widgets.zig").pong_bg_color;

pub const SceneTag = enum {
    MainMenu,
    Options,
    Gameplay,
    // Agregar más escenas según sea necesario
};

pub const Scene = union(SceneTag) {
    MainMenu: MainMenuScene,
    Options: OptionsScene,
    Gameplay: GameplayScene,
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
            .Gameplay => .{ .Gameplay = try GameplayScene.init(allocator, .{
                .background_color = options.background_color,
            }) },
        };
    }

    // ===== Métodos de la Scene =====

    pub fn update(self: *Scene) void {
        return switch (self.*) {
            .MainMenu => |*scene| scene.update(),
            .Options => |*scene| scene.update(),
            .Gameplay => |*scene| scene.update(),
        };
    }

    pub fn draw(self: *const Scene) void {
        switch (self.*) {
            .MainMenu => |*scene| scene.draw(),
            .Options => |*scene| scene.draw(),
            .Gameplay => |*scene| scene.draw(),
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
            .Gameplay => |*scene| scene.deinit(allocator),
        }
    }
};
