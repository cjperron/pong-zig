const std = @import("std");

const rl = @import("raylib");

const AppState = @import("../app_state.zig").AppState;
const available_resolutions = @import("../app_state.zig").available_resolutions;
const Callback = @import("../root.zig").Callback;
const U8StringZ = @import("../root.zig").U8StringZ;
const Widget = @import("../widgets.zig").Widget;
const Button = @import("../widgets.zig").Button;
const pong_bg_color = @import("../widgets.zig").pong_bg_color;

pub const OptionsScene = struct {
    widgets: *std.ArrayList(Widget), // Ya que se va a actualizar la len del slice interno, tiene que ser una referencia, sino se copia la antigua len.
    background_color: rl.Color,

    new_config: *AppState.Config, // Es una copia de la configuración actual, donde se aplican los cambios antes de confirmar. WARNING: dinamico en memoria

    pub fn init(allocator: std.mem.Allocator, options: struct {
        background_color: rl.Color = pong_bg_color,
    }) !OptionsScene {
        var widgets = try allocator.create(std.ArrayList(Widget));
        errdefer allocator.destroy(widgets);
        widgets.* = try std.ArrayList(Widget).initCapacity(allocator, 16);
        errdefer widgets.deinit(allocator);

        const new_config: *AppState.Config = try allocator.create(AppState.Config);
        errdefer allocator.destroy(new_config);

        new_config.* = AppState.getInstance().config; // Copio la configuración actual

        var scene = OptionsScene{
            .widgets = widgets,
            .background_color = options.background_color,
            .new_config = new_config,
        };

        // ===== Widgets =====

        // Título
        var options_text = try Widget.initUnderlinedText(allocator, .{
            .text = "Opciones",
            .layout_info = .{ .Anchored = .{ .anchor = .TopLeft, .offset_x = 20, .offset_y = 20 } },
            .font_size = 60,
        });

        errdefer options_text.deinit(allocator);

        try scene.widgets.append(allocator, options_text);

        const display_config = AppState.getInstance().config.display_config;

        // =========================
        // ==== Grupo de textos ====
        // =========================

        // Texto auxiliar para inicializacion
        var aux_txt = try U8StringZ.initFormat(allocator, "{d} x {d}", .{ display_config.getResolution().width, display_config.getResolution().height });
        errdefer aux_txt.deinit(allocator);
        defer aux_txt.deinit(allocator);

        // Lista de Widgets de texto
        var widget_texts = try std.ArrayList(Widget).initCapacity(allocator, 8);
        errdefer widget_texts.deinit(allocator);

        var resolution_text = try Widget.initText(allocator, .{
            .text = aux_txt.toSlice(),
            .layout_info = .{
                .Absolute = .{},
            },
            .font_size = 30,
        });

        try widget_texts.append(allocator, resolution_text);

        errdefer resolution_text.deinit(allocator);

        try aux_txt.format(allocator, "{s}", .{if (display_config.fullscreen) "Sí" else "No"});

        var fullscreen_text = try Widget.initText(allocator, .{
            .text = aux_txt.toSlice(),
            .layout_info = .{
                .Absolute = .{},
            },
            .font_size = 30,
        });
        errdefer fullscreen_text.deinit(allocator);
        try widget_texts.append(allocator, fullscreen_text);


        // Texto mostrar FPS

        try aux_txt.format(allocator, "{s}", .{if (AppState.getInstance().config.options.display_fps) "Sí" else "No"});

        var show_fps_text = try Widget.initText(allocator, .{
			.text = aux_txt.toSlice(),
			.layout_info = .{
				.Absolute = .{},
			},
			.font_size = 30,
		});

        errdefer show_fps_text.deinit(allocator);

        try widget_texts.append(allocator, show_fps_text);

        // Seguir agregando textos para TODAS las opciones...

        // Finalmente, creo el grupo de textos
        const widget_group_texts = try Widget.initWidgetGroup(.{
            .widgets = widget_texts,
            .layout_info = .{ .Anchored = .{ .anchor = .TopLeft, .offset_x = 400, .offset_y = 150 } },
            .spacing = 35,
        });

        try scene.widgets.append(allocator, widget_group_texts);
        // ============================
        // ==== Grupos de Botones =====
        // ============================

        // Lista de Widgets de botones
        var widget_buttons = try std.ArrayList(Widget).initCapacity(allocator, 8);
        errdefer widget_buttons.deinit(allocator);

        // Boton de Resolución
        const resolution_button_ctx = struct {
            selected_resolution: *usize,
            resolution_text: U8StringZ,
            dummy_allocator: std.mem.Allocator,
            pub fn call(self: *@This()) void {
                self.selected_resolution.* = (self.selected_resolution.* + 1) % available_resolutions.len;
                const res = available_resolutions[self.selected_resolution.*];
                self.resolution_text.format(self.dummy_allocator, "{d} x {d}", .{ res.width, res.height }) catch unreachable; // si ya existe la string, no puede fallar
            }
        }{
            .selected_resolution = &scene.new_config.display_config.selected_resolution_index,
            .dummy_allocator = allocator,
            .resolution_text = resolution_text.inner.text.text,
        };

        var resolution_button = try Widget.initButton(allocator, .{
            .label = "Resolución:",
            .font_size = 30,
            .layout_info = .{ .Anchored = .{ .anchor = .TopLeft, .offset_x = 100, .offset_y = 150 } },
            .bg_color = options.background_color,
            .on_click = try Callback.init(allocator, &resolution_button_ctx),
        });
        errdefer resolution_button.deinit(allocator);
        try widget_buttons.append(allocator, resolution_button);

        const fullscreen_button_ctx = struct {
            fullscreen_text: U8StringZ,
            new_config: *AppState.Config,
            dummy_allocator: std.mem.Allocator,
            pub fn call(self: *@This()) void {
                self.new_config.display_config.fullscreen = !self.new_config.display_config.fullscreen;
                self.fullscreen_text.format(self.dummy_allocator, "{s}", .{if (self.new_config.display_config.fullscreen) "Sí" else "No"}) catch unreachable;
            }
        }{
            .fullscreen_text = fullscreen_text.inner.text.text,
            .new_config = scene.new_config,
            .dummy_allocator = allocator,
        };

        var fullscreen_button = try Widget.initButton(allocator, .{
            .label = "Pantalla Completa:",
            .font_size = 30,
            .layout_info = .{ .Anchored = .{ .anchor = .TopLeft, .offset_x = 100, .offset_y = 185 } },
            .bg_color = options.background_color,
            .on_click = try Callback.init(allocator, &fullscreen_button_ctx),
        });
        errdefer fullscreen_button.deinit(allocator);
        try widget_buttons.append(allocator, fullscreen_button);


        // Seguir agregando botones para TODAS las opciones...

        // Boton Mostrar FPS

        const show_fps_button_ctx = struct {
			show_fps_text: U8StringZ,
			new_config: *AppState.Config,
			dummy_allocator: std.mem.Allocator,
			pub fn call(self: *@This()) void {
				self.new_config.options.display_fps = !self.new_config.options.display_fps;
				self.show_fps_text.format(self.dummy_allocator, "{s}", .{if (self.new_config.options.display_fps) "Sí" else "No"}) catch unreachable;
			}
		}{
			.show_fps_text = show_fps_text.inner.text.text,
			.new_config = scene.new_config,
			.dummy_allocator = allocator,
		};

		var show_fps_button = try Widget.initButton(allocator, .{
			.label = "Mostrar FPS:",
			.font_size = 30,
			.layout_info = .{ .Anchored = .{ .anchor = .TopLeft, .offset_x = 100, .offset_y = 220 } },
			.bg_color = options.background_color,
			.on_click = try Callback.init(allocator, &show_fps_button_ctx),

		});

		errdefer show_fps_button.deinit(allocator);

		try widget_buttons.append(allocator, show_fps_button);


        // Finalmente, creo el grupo de botones
        const widget_group_buttons = try Widget.initWidgetGroup(.{
            .widgets = widget_buttons,
            .layout_info = .{ .Anchored = .{ .anchor = .TopLeft, .offset_x = 100, .offset_y = 150 } },
            .spacing = 5,
        });

        try scene.widgets.append(allocator, widget_group_buttons);

        // ============================
        // ==== Botones Inferiores ====
        // ============================
        // Boton de Volver
        const volver_button_ctx = struct {
            pub fn call(self: *const @This()) void {
                _ = self;
                const app_state = AppState.getInstanceMut();
                app_state.requested_scene = .MainMenu;
            }
        }{};

        var volver_button = try Widget.initButton(allocator, .{
            .label = "Volver",
            .font_size = 40,
            .bg_color = options.background_color,
            .layout_info = .{ .Anchored = .{ .anchor = .BottomLeft, .offset_x = 100, .offset_y = 100 } },
            .on_click = try Callback.init(allocator, &volver_button_ctx),
        });

        errdefer volver_button.deinit(allocator);

        try scene.widgets.append(allocator, volver_button);

        // Boton Aplicar

        const aplicar_button_ctx = struct {
            new_config: *AppState.Config,
            widgets: *std.ArrayList(Widget),
            pub fn call(self: *const @This()) void {
                const app_state = AppState.getInstanceMut();
                const toggle_fullscreen = app_state.config.display_config.fullscreen != self.new_config.display_config.fullscreen;
                app_state.config = self.new_config.*;
                app_state.save() catch {
                	std.debug.print("WARNING: could not save configuration to file.\n", .{});
                }; // Guardo la configuración (si falla, no hago nada)

                // Reconfigurar ventana
                const res = app_state.config.display_config.getResolution();
                rl.setWindowSize(res.width, res.height);
                // Mover ventana al centro
                const monitor = rl.getCurrentMonitor();
                const monitor_width = rl.getMonitorWidth(monitor);
                const monitor_height = rl.getMonitorHeight(monitor);
                rl.setWindowPosition(@divFloor(monitor_width - res.width, 2), @divFloor(monitor_height - res.height, 2));

                for (self.widgets.items) |*widget| {
                    widget.reposition();
                }

                // Seteo fullscreen
                if (toggle_fullscreen) {
					rl.toggleFullscreen();
				}
            }
        }{
            .new_config = scene.new_config,
            .widgets = scene.widgets,
        };

        var aplicar_button = try Widget.initButton(allocator, .{
            .label = "Aplicar",
            .font_size = 40,
            .bg_color = options.background_color,
            .layout_info = .{ .Anchored = .{ .anchor = .BottomRight, .offset_x = 250, .offset_y = 100 } },
            .on_click = try Callback.init(allocator, &aplicar_button_ctx),
        });

        errdefer aplicar_button.deinit(allocator);

        try scene.widgets.append(allocator, aplicar_button);

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
        allocator.destroy(self.widgets);

        allocator.destroy(self.new_config);
    }
};
