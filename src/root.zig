//! By convention, root.zig is the root source file when making a library.
const std = @import("std");
const rl = @import("raylib");

pub const display = struct {
	pub const widgets = @import("widgets.zig");
	pub const scene = @import("scene.zig");
};


pub const app = struct {
	pub const AppState = @import("app_state.zig").AppState;
    pub const sim = @import("game/sim.zig");
};

// ===== Closures genéricas =====

pub const Callback = struct {
    ptr: *anyopaque,
    callFn: *const fn (*anyopaque) void,
    deinitFn: *const fn (*anyopaque, std.mem.Allocator) void,
    allocator: std.mem.Allocator,

    pub inline fn call(self: Callback) void {
        self.callFn(self.ptr);
    }

    pub fn deinit(self: Callback) void {
        self.deinitFn(self.ptr, self.allocator);
    }

    /// Crea callback desde cualquier struct con método `call`
    /// Aloca una copia del closure en el heap
    pub fn init(allocator: std.mem.Allocator, closure: anytype) !Callback {
        const T = @TypeOf(closure.*);
        if (!@hasDecl(T, "call")) {
            @compileError("Closure must have a 'call' method");
        }

        // Alocar copia en el heap
        const heap_closure = try allocator.create(T);
        heap_closure.* = closure.*;

        const wrapper = struct {
            fn wrap(ptr: *anyopaque) void {
                const self: *T = @ptrCast(@alignCast(ptr));
                self.call();
            }

            fn deinitWrap(ptr: *anyopaque, alloc: std.mem.Allocator) void {
                const self: *T = @ptrCast(@alignCast(ptr));
                alloc.destroy(self);
            }
        };

        return .{
            .ptr = heap_closure,
            .callFn = wrapper.wrap,
            .deinitFn = wrapper.deinitWrap,
            .allocator = allocator,
        };
    }
};
