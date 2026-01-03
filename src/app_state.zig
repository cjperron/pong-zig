const std = @import("std");
const rl = @import("raylib");
const SceneTag = @import("scene.zig").SceneTag;

pub const AppState = struct {
    should_exit: bool,
    current_scene: SceneTag,
    requested_scene: ?SceneTag,
    display_config: DisplayConfig,
    options: struct {
        display_fps: bool,
    },

    pub fn getInstanceMut() *AppState {
        if (!is_initialized) {
            instance = AppState.load() catch AppState.default();
            is_initialized = true;
        }
        return &instance;
    }

    pub fn getInstance() *const AppState {
        return &AppState.getInstanceMut().*; // "re-borrow"
    }

    fn default() AppState {
        return AppState{
            .should_exit = false,
            .current_scene = .MainMenu,
            .requested_scene = null,
            .display_config = DisplayConfig.default(),
            .options = .{
                .display_fps = true,
            },
        };
    }

    fn load() !AppState {
		// Placeholder for loading configuration from a file or other source
		return AppState.default();
	}

	pub fn save(self: *const AppState) !void {
		// Placeholder for saving configuration to a file or other destination
		_ = self;
	}
};

var instance: AppState = undefined;
var is_initialized: bool = false;

pub const DisplayConfig = struct {
    width: i32,
    height: i32,
    title: []const u8,
    background_color: rl.Color,

    pub fn init(width: u32, height: u32, title: []const u8, background_color: rl.Color) DisplayConfig {
        return DisplayConfig{
            .width = width,
            .height = height,
            .title = title,
            .background_color = background_color,
        };
    }

    pub fn default() DisplayConfig {
		return DisplayConfig{
			.width = 1366,
			.height = 768,
			.title = "Pong Zig",
			.background_color = rl.Color{ .r = 20, .g = 20, .b = 30, .a = 255 },
		};
	}
};
