const std = @import("std");
const rl = @import("raylib");
const SceneTag = @import("scene.zig").SceneTag;
const pong_bg_color = @import("widgets.zig").pong_bg_color;

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
            .display_config = DisplayConfig.init(.{}),
            .options = .{
                .display_fps = false,
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

pub const Resolution = struct {
    width: i32,
    height: i32,

    const Self = @This();

    pub const res_800x600 = Resolution{ .width = 800, .height = 600 };
    pub const res_1024x768 = Resolution{ .width = 1024, .height = 768 };
    pub const res_1280x720 = Resolution{ .width = 1280, .height = 720 };
    pub const res_1366x768 = Resolution{ .width = 1366, .height = 768 };
    pub const res_1600x900 = Resolution{ .width = 1600, .height = 900 };
    pub const res_1920x1080 = Resolution{ .width = 1920, .height = 1080 };
    pub const res_2560x1440 = Resolution{ .width = 2560, .height = 1440 };
    pub const res_3840x2160 = Resolution{ .width = 3840, .height = 2160 };
};

pub const DisplayConfig = struct {
    resolution: Resolution,
    title: []const u8,
    background_color: rl.Color,

    const Self = @This();

    pub fn init(options: struct {
        resolution: Resolution = Resolution.res_1366x768,
        title: []const u8 = "Pong Zig",
        background_color: rl.Color = pong_bg_color,
    }) Self {
        return Self{
            .resolution = options.resolution,
            .title = options.title,
            .background_color = options.background_color,
        };
    }
};
