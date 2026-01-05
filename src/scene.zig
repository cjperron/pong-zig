const std = @import("std");
const rl = @import("raylib");
const Widget = @import("widgets.zig").Widget;
const Button = @import("widgets.zig").Button;
const Callback = @import("root.zig").Callback;
const U8StringZ = @import("root.zig").U8StringZ;

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

    pub fn init(allocator: std.mem.Allocator, options: struct {
        background_color: rl.Color = pong_bg_color,
    }) !MainMenuScene {
        var scene = MainMenuScene{
            .widgets = try std.ArrayList(Widget).initCapacity(allocator, 16),
            .background_color = options.background_color,
        };

        errdefer scene.widgets.deinit(allocator);

        const display_width = AppState.getInstance().display_config.width;
        // const display_height = AppState.getInstance().display_config.height;
        // ===== Widgets =====
        const titulo = Widget.initUnderlinedText(.{
            .text = "PONG",
            .x = @divTrunc(display_width - rl.measureText("PONG", 120), 2),
            .y = 150,
            .font_size = 120,
        });

        try scene.widgets.append(allocator, titulo);

        var main_menu_buttons = try std.ArrayList(Button).initCapacity(allocator, 3);
        // Botones
        //

        const jugar_btn_ctx = struct {
            pub fn call(self: *const @This()) void {
                _ = self;
                const app_state = AppState.getInstanceMut();
                app_state.requested_scene = .Gameplay;
            }
        }{};

        const jugar_btn = Button.init(.{
            .label = "Jugar",
            .font_size = 40,
            .bg_color = options.background_color,
            .on_click = try Callback.init(allocator, &jugar_btn_ctx),
        });

        try main_menu_buttons.append(allocator, jugar_btn);

        const opciones_ctx = struct {
            pub fn call(self: *const @This()) void {
                _ = self;
                const app_state = AppState.getInstanceMut();
                app_state.requested_scene = .Options;
            }
        }{};

        const options_btn = Button.init(.{
            .label = "Opciones",
            .font_size = 40,
            .bg_color = options.background_color,
            .on_click = try Callback.init(allocator, &opciones_ctx),
        });

        try main_menu_buttons.append(allocator, options_btn);

        const salir_ctx = struct {
            pub fn call(self: *const @This()) void {
                _ = self;
                const app_state = AppState.getInstanceMut();
                app_state.should_exit = true;
            }
        }{};

        const salir_btn = Button.init(.{
            .label = "Salir",
            .font_size = 40,
            .bg_color = options.background_color,
            .on_click = try Callback.init(allocator, &salir_ctx),
        });

        try main_menu_buttons.append(allocator, salir_btn);

        const button_group_widget = Widget.initButtonGroup(.{
            .buttons = main_menu_buttons,
            .selected_index = 0,
            .x = @divTrunc(display_width - 200, 2),
            .y = 400,
            .spacing = 20,
        });

        try scene.widgets.append(allocator, button_group_widget);

        return scene;
    }

    pub fn update(self: *MainMenuScene) void {
        for (self.widgets.items) |*widget| {
            widget.update();
        }
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
    widgets: std.ArrayList(Widget),
    background_color: rl.Color,

    // Textos mutables.
    resolution_string: U8StringZ,

    pub fn init(allocator: std.mem.Allocator, options: struct {
        background_color: rl.Color = pong_bg_color,
    }) !OptionsScene {
        var scene = OptionsScene{
            .widgets = try std.ArrayList(Widget).initCapacity(allocator, 16),
            .background_color = options.background_color,
            .resolution_string = undefined,
        };
        errdefer scene.widgets.deinit(allocator);

        // ===== Widgets =====
        //
        // Título
        const options_text = Widget.initUnderlinedText(.{
            .text = "Opciones",
            .x = 20,
            .y = 20,
            .font_size = 60,
        });

        try scene.widgets.append(allocator, options_text);

        // Boton de resolución
        const resolution_button_ctx = struct {
            pub fn call(self: *const @This()) void {
                _ = self;
                // Aquí iría la lógica para cambiar la resolución
                // CICLAR ENTRE VARIAS RESOLUCIONES PREDEFINIDAS
            }
        }{};

        const resolution_button = Widget.initButton(.{
            .label = "Resolucion:",
            .font_size = 30,
            .x = 100,
            .y = 150,
            .bg_color = options.background_color,
            .on_click = try Callback.init(allocator, &resolution_button_ctx),
        });

        try scene.widgets.append(allocator, resolution_button);

        const display_config = AppState.getInstance().display_config;

        scene.resolution_string = try U8StringZ.initFormat(allocator, "{d} x {d}", .{ display_config.width, display_config.height });

        errdefer scene.resolution_string.deinit(allocator);

        const resolution_text = Widget.initText(.{
            .text = scene.resolution_string.toSlice(),
            .x = 300,
            .y = 150,
            .font_size = 30,
        });

        try scene.widgets.append(allocator, resolution_text);

        // Boton de Volver
        const back_button_ctx = struct {
            pub fn call(self: *const @This()) void {
                _ = self;
                const app_state = AppState.getInstanceMut();
                app_state.requested_scene = .MainMenu;
            }
        }{};

        const back_button = Widget.initButton(.{
            .label = "Volver",
            .font_size = 40,
            .bg_color = options.background_color,
            .x = 100,
            .y = 400,
            .on_click = try Callback.init(allocator, &back_button_ctx),
        });
        try scene.widgets.append(allocator, back_button);

        return scene;
    }

    pub fn update(self: *OptionsScene) void {
        for (self.widgets.items) |*widget| {
            widget.update();
        }
    }

    pub fn draw(self: *const OptionsScene) void {
        for (self.widgets.items) |*widget| {
            widget.draw();
        }
    }

    pub fn deinit(self: *OptionsScene, allocator: std.mem.Allocator) void {
        for (self.widgets.items) |*widget| {
            widget.deinit(allocator);
        }
        self.widgets.deinit(allocator);
        // Liberar la cadena allocada
        self.resolution_string.deinit(allocator);
    }
};

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
