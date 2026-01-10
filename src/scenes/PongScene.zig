const std = @import("std");

const rl = @import("raylib");

const pong_bg_color = @import("../widget.zig").pong_bg_color;
const widget = @import("../widget.zig");
const Widget = widget.Widget;
const AppState = @import("../app_state.zig").AppState;
const Callback = @import("../root.zig").Callback;
const U8StringZ = @import("../string.zig").U8StringZ;
const PongState = @import("../game/pong/PongState.zig");

const Self = @This();

paused: bool,
pause_widgets: *std.ArrayList(Widget), // Widgets para el menu de pausa

static_widgets: *std.ArrayList(Widget), // Widgets que siempre estan quietos

pub fn init(allocator: std.mem.Allocator, options: struct {
    background_color: rl.Color = pong_bg_color,
}) !Self {
    _ = options;
    var scene = Self{ .paused = false, .static_widgets = undefined, .pause_widgets = undefined };

    // ==============================
    // ===== Widgets estáticos =====
    // =============================

    scene.static_widgets = try allocator.create(std.ArrayList(Widget));
    errdefer allocator.destroy(scene.static_widgets);
    scene.static_widgets.* = try std.ArrayList(Widget).initCapacity(allocator, 8);
    errdefer scene.static_widgets.deinit(allocator);

    // Cancha (fondo)
    const offset = 20;
    const court_sep_line = Widget.initLine(.{
        .direction = widget.north,
        .layout_info = .{ .Anchored = .{ .anchor = .Bottom, .offset_y = -offset } },
        .length = @floatFromInt(rl.getScreenHeight() - offset * 2),
        .color = .white,
        .thickness = 4,
    });

    try scene.static_widgets.append(allocator, court_sep_line);

    var player_1_score_txt = try Widget.initText(allocator, .{
        .text = "0",
        .font_size = 80,
        .color = .white,
        .layout_info = .{ .Anchored = .{
            .anchor = .Top,
            .offset_x = -40,
            .offset_y = 20,
        } },
    });

    const player_1_score_txt_ctx = struct {
        player_score_txt: U8StringZ,
        allocator: std.mem.Allocator,
        pub fn call(self: *@This()) void {
            const pong_state = PongState.getInstance();
            self.player_score_txt.format(self.allocator, "{d}", .{pong_state.player1_score}) catch unreachable; // Si el callback falla, es un error grave, no hay mas memoria.
        }
    }{
        .player_score_txt = player_1_score_txt.inner.text.text,
        .allocator = allocator,
    };

    player_1_score_txt.inner.text.on_update = try Callback.init(allocator, &player_1_score_txt_ctx);

    errdefer player_1_score_txt.deinit(allocator);
    try scene.static_widgets.append(allocator, player_1_score_txt);

    var player_2_score_txt = try Widget.initText(allocator, .{
		.text = "0",
		.font_size = 80,
		.color = .white,
		.layout_info = .{ .Anchored = .{
			.anchor = .Top,
			.offset_x = 40,
			.offset_y = 20,
		} },
	});

    const player_2_score_txt_ctx = struct {
		player_score_txt: U8StringZ,
		allocator: std.mem.Allocator,
		pub fn call(self: *@This()) void {
			const pong_state = PongState.getInstance();
			self.player_score_txt.format(self.allocator, "{d}", .{pong_state.player2_score}) catch unreachable; // Si el callback falla, es un error grave, no hay mas memoria.
		}
	}{
		.player_score_txt = player_2_score_txt.inner.text.text,
		.allocator = allocator,
	};

	player_2_score_txt.inner.text.on_update = try Callback.init(allocator, &player_2_score_txt_ctx);
	errdefer player_2_score_txt.deinit(allocator);
	try scene.static_widgets.append(allocator, player_2_score_txt);
    // ============================
    // ===== Widgets de pausa =====
    // ============================

    scene.pause_widgets = try allocator.create(std.ArrayList(Widget));
    errdefer allocator.destroy(scene.pause_widgets);
    scene.pause_widgets.* = try std.ArrayList(Widget).initCapacity(allocator, 8);
    errdefer scene.pause_widgets.deinit(allocator);

    var pause_text = try Widget.initText(allocator, .{
        .text = "Pausado",
        .font_size = 60,
        .color = .light_gray,
        .layout_info = .{ .Anchored = .{
            .anchor = .Center,
        } },
    });
    errdefer pause_text.deinit(allocator);

    try scene.pause_widgets.append(allocator, pause_text);

    // Boton salir (vuelta al menu principal)
    const exit_button_ctx = struct {
        pub fn call(self: *const @This()) void {
            _ = self;
            const app_state = AppState.getInstanceMut();
            app_state.requested_scene = .MainMenu;
        }
    }{};

    var exit_button = try Widget.initButton(allocator, .{
        .label = "Salir al menú principal",
        .font_size = 30,
        .color = .light_gray,
        .layout_info = .{ .Anchored = .{
            .anchor = .Center,
            .offset_y = 80,
        } },
        .on_click = try Callback.init(allocator, &exit_button_ctx),
    });
    errdefer exit_button.deinit(allocator);

    try scene.pause_widgets.append(allocator, exit_button);
    return scene;
}

pub fn update(self: *Self) void {
    if (rl.isKeyPressed(.escape)) {
        self.paused = !self.paused;
    }

    if (self.paused) {
        for (self.pause_widgets.items) |*w| {
            w.update();
        }
        return;
    }
    // no pausado,
    // Actualizar elementos del juego aquí!

    // Cancha
}

pub fn draw(self: *const Self) void {
    if (self.paused) {
        for (self.pause_widgets.items) |*w| {
            w.draw();
        }
        return;
    }
    // no pausado,
    // Dibujar elementos del juego aquí!
    for (self.static_widgets.items) |*w| {
        w.draw();
    }
}

pub fn deinit(self: *Self, allocator: std.mem.Allocator) void {
    self.pause_widgets.deinit(allocator);
    allocator.destroy(self.pause_widgets);
    self.static_widgets.deinit(allocator);
    allocator.destroy(self.static_widgets);
}
