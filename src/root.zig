//! By convention, root.zig is the root source file when making a library.
const std = @import("std");
const rl = @import("raylib");

pub const widgets = @import("widgets.zig");

pub const game = struct {
    pub const sim = @import("game/sim.zig");
};

// ===== Closures genéricas =====

pub const Callback = struct {
    ptr: *anyopaque,
    callFn: *const fn (*anyopaque) void,

    pub inline fn call(self: Callback) void {
        self.callFn(self.ptr);
    }

    /// Crea callback desde cualquier struct con método `call`
    pub fn init(closure: anytype) Callback {
        const T = @TypeOf(closure.*);
        if (!@hasDecl(T, "call")) {
            @compileError("Closure must have a 'call' method");
        }
        const wrapper = struct {
            fn wrap(ptr: *anyopaque) void {
                const self: @TypeOf(closure) = @ptrCast(@alignCast(ptr));
                self.call();
            }
        };
        return .{ .ptr = closure, .callFn = wrapper.wrap };
    }
};

pub const GameState = struct {
    // Define the game state here
    // For example, player positions, scores, etc.
};

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
                .width = 1280,
                .height = 720,
            },
            .title = "Pong - Main Menu",
            .background_color = rl.Color{ .r = 20, .g = 20, .b = 30, .a = 255 }, // default black theme.
        };
    }

    pub fn load() !DisplayConfig {
        // Placeholder for loading configuration from a file or other source
        return DisplayConfig.default();
    }
};
