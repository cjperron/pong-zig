const std = @import("std");

const rl = @import("raylib");

const pong_bg_color = @import("../widget.zig").pong_bg_color;

const Widget = @import("../widget.zig").Widget;

pub const GameplayScene = struct {
    widgets: *std.ArrayList(Widget),

    const Self = @This();


    pub fn init(allocator: std.mem.Allocator, options: struct {
        background_color: rl.Color = pong_bg_color,
    }) !Self {
        _ = options;
        const widgets = try allocator.create(std.ArrayList(Widget));
        widgets.* = try std.ArrayList(Widget).initCapacity(allocator, 16);

        const scene = Self{
            .widgets = widgets,
        };

        // Example InputText widget
        const input_text = try Widget.initTextInput(allocator, .{
			.default_text = "Enter your name",
			.font_size = 50,
			.char_limit = 20,
			.layout_info = .{
				.Anchored = .{ .anchor = .Center, }
			},
		});
        try scene.widgets.append(allocator, input_text);

        return scene;
    }

    pub fn update(self: *Self) void {
        for (self.widgets.items) |*widget| {
            widget.update();
            // PRUEBA
            widget.reposition();
        }

        if (rl.isKeyPressed(.escape)) {
        	const app_state = @import("../app_state.zig").AppState.getInstanceMut();
			app_state.requested_scene = .MainMenu;
        }
    }

    pub fn draw(self: *const GameplayScene) void {
        for (self.widgets.items) |*widget| {
            widget.draw();
        }
    }

    pub fn deinit(self: *GameplayScene, allocator: std.mem.Allocator) void {
        self.widgets.deinit(allocator);
        allocator.destroy(self.widgets);
    }
};
