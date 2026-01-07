const std = @import("std");
const rl = @import("raylib");
const SceneTag = @import("scene.zig").SceneTag;

const deserialize = @import("serialization.zig").deserialize;
const serialize = @import("serialization.zig").serialize;

const pong_bg_color = @import("widgets.zig").pong_bg_color;

pub const AppState = struct {
    should_exit: bool,
    current_scene: SceneTag,
    requested_scene: ?SceneTag,
    config: struct {
        display_config: DisplayConfig,
        options: struct {
            display_fps: bool,
        },
    },
    const Self = @This();
    pub const Config = @TypeOf(@as(Self, undefined).config);

    pub fn getInstanceMut() *Self {
        if (!is_initialized) {
            instance = Self.load() catch Self.default();
            is_initialized = true;
        }
        return &instance;
    }

    pub fn getInstance() *const Self {
        return &Self.getInstanceMut().*; // "re-borrow"
    }

    fn default() Self {
        return Self{ .should_exit = false, .current_scene = .MainMenu, .requested_scene = null, .config = .{
            .display_config = DisplayConfig.init(.{}),
            .options = .{
                .display_fps = false,
            },
        } };
    }

    fn load() !Self {
        const file = std.fs.cwd().openFile("config.pz", .{}) catch { // Si no existe el archivo, defaulteamos.
            const default_instance = Self.default();
            // Si no existe, intentamos crearlo con los defaults
            default_instance.save() catch {};
            return default_instance;
        };
        defer file.close();

        // Creamos el Io.Reader
        var buf: [16 * 1024]u8 = undefined;
        var fr = file.reader(&buf);
        const r = &fr.interface;

        // Leemos la config del archivo
        var result = Self{ .should_exit = false, .current_scene = .MainMenu, .requested_scene = null, .config = undefined };
        const temp_config = try deserialize(Config, r, std.heap.page_allocator);
        result.config = temp_config;
        return result;
    }

    pub fn save(self: *const Self) !void {
        const file = try std.fs.cwd().createFile("config.pz", .{});
        defer file.close();

        // Creamos el Io.Writer
        var buf: [16 * 1024]u8 = undefined;
        var fw = file.writer(&buf);
        const w = &fw.interface;

        // Escribimos la config al archivo
        try serialize(Config, w, self.config);
        try w.flush();
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

pub const available_resolutions = [_]Resolution{
    Resolution.res_800x600,
    Resolution.res_1024x768,
    Resolution.res_1280x720,
    Resolution.res_1366x768,
    Resolution.res_1600x900,
    Resolution.res_1920x1080,
    Resolution.res_2560x1440,
    Resolution.res_3840x2160,
};

pub const DisplayConfig = struct {
    selected_resolution_index: usize,
    title: []const u8,
    background_color: rl.Color,
    fullscreen: bool,

    const Self = @This();

    pub fn init(
        options: struct {
            selected_resolution_index: usize = 3, // Default to 1366x768
            title: []const u8 = "Pong Zig",
            background_color: rl.Color = pong_bg_color,
            fullscreen: bool = false,
        },
    ) Self {
        return Self{
            .title = options.title,
            .background_color = options.background_color,
            .selected_resolution_index = options.selected_resolution_index,
            .fullscreen = options.fullscreen,
        };
    }

    pub fn getResolution(self: *const Self) Resolution {
        return available_resolutions[self.selected_resolution_index];
    }
};
