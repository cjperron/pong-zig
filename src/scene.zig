const std = @import("std");
const rl = @import("raylib");
const Widget = @import("widgets.zig").Widget;
const Button = @import("widgets.zig").Button;
const Callback = @import("root.zig").Callback;
const config = @import("config.zig");
const AppState = @import("app_state.zig").AppState;

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
        background_color: rl.Color = config.pong_bg_color,
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

    pub fn update(self: *Scene) ?SceneTag {
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
    }

    pub fn deinit(self: *Scene, allocator: std.mem.Allocator) void {
        switch (self.*) {
            .MainMenu => |*scene| scene.deinit(allocator),
            .Options => |*scene| scene.deinit(allocator),
            .Gameplay => |*scene| scene.deinit(allocator),
        }
    }
};

pub const MainMenuScene = struct {
    widgets: std.ArrayList(Widget),
    background_color: rl.Color,
    salir_ctx: struct {
        should_exit: *bool,
        pub fn call(self: *@This()) void {
            self.should_exit.* = true;
        }
    },

    pub fn init(allocator: std.mem.Allocator, options: struct {
        background_color: rl.Color = config.pong_bg_color,
    }) !MainMenuScene {
        var scene = MainMenuScene{
            .widgets = try std.ArrayList(Widget).initCapacity(allocator, 16),
            .background_color = options.background_color,
            .salir_ctx = undefined,
        };

        errdefer scene.widgets.deinit(allocator);

        const resolution = config.DisplayConfig.getInstance().res;

        // ===== Widgets =====
        const titulo = Widget.initUnderlinedText(.{
            .text = "PONG",
            .x = @divTrunc(resolution.width - rl.measureText("PONG", 120), 2),
            .y = 150,
            .font_size = 120,
        });

        try scene.widgets.append(allocator, titulo);

        var main_menu_buttons = try std.ArrayList(Button).initCapacity(allocator, 3);
        // Botones
        const jugar_btn = Button.init(.{
            .label = "Jugar",
            .font_size = 40,
            .bg_color = options.background_color,
        });

        try main_menu_buttons.append(allocator, jugar_btn);

        const options_btn = Button.init(.{
            .label = "Opciones",
            .font_size = 40,
            .bg_color = options.background_color,
        });

        try main_menu_buttons.append(allocator, options_btn);

        scene.salir_ctx = .{ .should_exit = &AppState.getInstanceMut().should_exit }; // inicializo el contexto

        const salir_btn = Button.init(.{
            .label = "Salir",
            .font_size = 40,
            .bg_color = options.background_color,
            .on_click = try Callback.init(allocator, &scene.salir_ctx),
        });

        try main_menu_buttons.append(allocator, salir_btn);

        const menu_selection_widget = Widget.initMenuSelection(.{
            .buttons = main_menu_buttons,
            .selected_index = 0,
            .x = @divTrunc(resolution.width - 200, 2),
            .y = 400,
            .spacing = 20,
        });

        try scene.widgets.append(allocator, menu_selection_widget);

        return scene;
    }

    pub fn update(self: *MainMenuScene) ?SceneTag {
        for (self.widgets.items) |*widget| {
            widget.update();
        }
        // TODO: signal to change scene
        return null;
    }

    pub fn draw(self: *const MainMenuScene) void {
        for (self.widgets.items) |widget| {
            widget.draw();
        }
    }

    pub fn deinit(self: *MainMenuScene, allocator: std.mem.Allocator) void {
        for (self.widgets.items) |*widget| {
            widget.deinit(allocator);
        }
        self.widgets.deinit(allocator);
    }
};

pub const OptionsScene = struct {
    pub fn init(allocator: std.mem.Allocator, options: struct {
        background_color: rl.Color = config.pong_bg_color,
    }) !OptionsScene {
        _ = allocator;
        _ = options;
        return OptionsScene{};
    }

    pub fn update(self: *OptionsScene) ?SceneTag {
        _ = self;
        return null;
    }

    pub fn draw(self: *const OptionsScene) void {
        _ = self;
    }

    pub fn deinit(self: *OptionsScene, allocator: std.mem.Allocator) void {
        _ = self;
        _ = allocator;
    }
};

pub const GameplayScene = struct {
    pub fn init(allocator: std.mem.Allocator, options: struct {
        background_color: rl.Color = config.pong_bg_color,
    }) !GameplayScene {
        _ = allocator;
        _ = options;
        return GameplayScene{};
    }

    pub fn update(self: *GameplayScene) ?SceneTag {
        _ = self;
        return null;
    }

    pub fn draw(self: *const GameplayScene) void {
        _ = self;
    }

    pub fn deinit(self: *GameplayScene, allocator: std.mem.Allocator) void {
        _ = self;
        _ = allocator;
    }
};
