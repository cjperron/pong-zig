const std = @import("std");
const rl = @import("raylib");

const U8StringZ = @import("../string.zig").U8StringZ;
const Callback = @import("../root.zig").Callback;
const Location = @import("../location.zig").Location;

pub const Text = struct {
    text: U8StringZ,
    font_size: i32,
    color: rl.Color,
    on_update: ?Callback,
    default: ?U8StringZ,

    const Self = @This();
    pub fn init(
        allocator: std.mem.Allocator,
        options: struct {
            text: []const u8,
            font_size: i32 = 20,
            color: rl.Color = .white,
            on_update: ?Callback = null,
            default: ?[]const u8 = null,
        },
    ) !Self {
        var aux = Self{
            .text = try U8StringZ.initFromSlice(allocator, options.text),
            .font_size = options.font_size,
            .color = options.color,
            .on_update = options.on_update,
            .default = null,
        };
        errdefer aux.text.deinit(allocator);
        if (options.default) |default_text| {
            aux.default = try U8StringZ.initFromSlice(allocator, default_text);
        }
        return aux;
    }

    pub fn update(self: *Self) void {
        if (self.on_update) |callback| {
            callback.call();
        }
    }

    pub fn draw(self: *const Self, location: Location) void {
        rl.drawText(self.text.toSlice(), location.x(), location.y(), self.font_size, self.color);
    }

    pub fn deinit(self: *Self, allocator: std.mem.Allocator) void {
        self.text.deinit(allocator);
    }

    pub fn resetToDefault(self: *Self, allocator: std.mem.Allocator) !void {
        if (self.default) |default_text| {
            try self.text.format(allocator, "{s}", .{default_text.toSlice()});
        }
    }

    pub fn getWidth(self: *const Self) i32 {
		return rl.measureText(self.text.toSlice(), self.font_size);
	}

	pub fn getHeight(self: *const Self) i32 {
		return self.font_size;
	}
};
