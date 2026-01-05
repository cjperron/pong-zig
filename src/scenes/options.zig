const std = @import("std");

const rl = @import("raylib");

const AppState = @import("../app_state.zig").AppState;
const Callback = @import("../root.zig").Callback;
const U8StringZ = @import("../root.zig").U8StringZ;
const Widget = @import("../widgets.zig").Widget;
const Button = @import("../widgets.zig").Button;
const pong_bg_color = @import("../widgets.zig").pong_bg_color;

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
        const options_text = try Widget.initUnderlinedText(allocator, .{
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

        const resolution_button = try Widget.initButton(allocator, .{
            .label = "Resolucion:",
            .font_size = 30,
            .x = 100,
            .y = 150,
            .bg_color = options.background_color,
            .on_click = try Callback.init(allocator, &resolution_button_ctx),
        });

        try scene.widgets.append(allocator, resolution_button);

        const display_config = AppState.getInstance().display_config;

        scene.resolution_string = try U8StringZ.initFormat(allocator, "{d} x {d}", .{ display_config.resolution.width, display_config.resolution.height });

        errdefer scene.resolution_string.deinit(allocator);

        const resolution_text = try Widget.initText(allocator, .{
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

        const back_button = try Widget.initButton(allocator, .{
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
