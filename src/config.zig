const std = @import("std");
const rl = @import("raylib");

pub const pong_bg_color = rl.Color{ .r = 20, .g = 20, .b = 30, .a = 255 }; // color a dedo

const Resolution = struct {
    width: i32,
    height: i32,
};

pub const DisplayConfig = struct {
    res: Resolution,
    title: []const u8,
    background_color: rl.Color,

    pub fn init(width: u32, height: u32, title: []const u8, background_color: rl.Color) DisplayConfig {
        return DisplayConfig{
            .res = Resolution{
                .width = width,
                .height = height,
            },
            .title = title,
            .background_color = background_color,
        };
    }

    pub fn default() DisplayConfig {
        return DisplayConfig{
            .res = Resolution{
                .width = 1366,
                .height = 768,
            },
            .title = "Pong Zig",
            .background_color = pong_bg_color, // default black theme.
        };
    }

    pub fn load() !DisplayConfig {
        // Placeholder for loading configuration from a file or other source
        return DisplayConfig.default();
    }

    pub fn save(self: *const DisplayConfig) !void {
        // Placeholder for saving configuration to a file or other destination
        _ = self;
    }

    pub fn getInstance() *const DisplayConfig {
        if (!is_initialized) {
            instance = DisplayConfig.load() catch DisplayConfig.default();
            is_initialized = true;
        }
        return &instance;
    }
};

var instance: DisplayConfig = undefined;
var is_initialized: bool = false;
