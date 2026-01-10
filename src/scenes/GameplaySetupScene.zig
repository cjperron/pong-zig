const std = @import("std");
const Rand = @import("../Rand.zig");
const rl = @import("raylib");

const pong_bg_color = @import("../widget.zig").pong_bg_color;

const Widget = @import("../widget.zig").Widget;
const AppState = @import("../app_state.zig").AppState;
const Callback = @import("../root.zig").Callback;
const U8StringZ = @import("../string.zig").U8StringZ;
const PongState = @import("../game/pong/PongState.zig");

widgets: *std.ArrayList(Widget), // Uso general

player_name_widget: Widget,

const Self = @This();

const ai_names = [_][:0]const u8{
    "Botín",
    "RoboCórner",
    "Pelotín",
    "Ciberraqueta",
    "AutoPaddle",
};

pub fn init(allocator: std.mem.Allocator, options: struct {
    background_color: rl.Color = pong_bg_color,
}) !Self {
    _ = options;
    const widgets = try allocator.create(std.ArrayList(Widget));
    errdefer allocator.destroy(widgets);
    widgets.* = try std.ArrayList(Widget).initCapacity(allocator, 16);
    errdefer widgets.deinit(allocator);

    var scene = Self{
        .widgets = widgets,
        .player_name_widget = undefined,
    };

    // Example InputText widget
    scene.player_name_widget = try Widget.initTextInput(allocator, .{
        .default_text = "Tu nombre:",
        .font_size = 50,
        .char_limit = 25,
        .layout_info = .{ .Anchored = .{
            .anchor = .Center,
        } },
    });
    errdefer scene.player_name_widget.deinit(allocator);

    return scene;
}

pub fn update(self: *Self) void {
    for (self.widgets.items) |*widget| {
        widget.update();
    }
    self.player_name_widget.update();
    self.player_name_widget.reposition();

    if (rl.isKeyPressed(.escape)) {
        AppState.getInstanceMut().requested_scene = .MainMenu;
    }

    if (rl.isKeyPressed(.enter)) {
        const rnd_index = Rand.getInstanceMut().rand.intRangeAtMost(usize, 0, ai_names.len-1);
        PongState.getInstanceMut().setPlayerNames(self.player_name_widget.inner.text_input.getText(), ai_names[rnd_index]);
        AppState.getInstanceMut().requested_scene = .Pong;
    }
}

pub fn draw(self: *const Self) void {
    for (self.widgets.items) |*widget| {
        widget.draw();
    }
    self.player_name_widget.draw();
}

pub fn deinit(self: *Self, allocator: std.mem.Allocator) void {
    self.widgets.deinit(allocator);
    allocator.destroy(self.widgets);
}
