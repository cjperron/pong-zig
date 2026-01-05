const std = @import("std");

const rl = @import("raylib");

const AppState = @import("../app_state.zig").AppState;
const Callback = @import("../root.zig").Callback;
const Widget = @import("../widgets.zig").Widget;
const Button = @import("../widgets.zig").Button;
const pong_bg_color = @import("../widgets.zig").pong_bg_color;

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

        const display_width = AppState.getInstance().display_config.resolution.width;
        // const display_height = AppState.getInstance().display_config.height;
        // ===== Widgets =====
        const titulo = try Widget.initUnderlinedText(allocator, .{
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

        const jugar_btn = try Button.init(allocator, .{
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

        const options_btn = try Button.init(allocator, .{
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

        const salir_btn = try Button.init(allocator, .{
            .label = "Salir",
            .font_size = 40,
            .bg_color = options.background_color,
            .on_click = try Callback.init(allocator, &salir_ctx),
        });

        try main_menu_buttons.append(allocator, salir_btn);

        const button_group_widget = Widget.initButtonGroup(.{
            .buttons = main_menu_buttons,
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
