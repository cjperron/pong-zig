const std = @import("std");
const rl = @import("raylib");
const Text = @import("./text.zig").Text;
const U8StringZ = @import("../string.zig").U8StringZ;
const Callback = @import("../root.zig").Callback;
const Location = @import("../location.zig").Location;

pub const UnderlinedText = struct {
    inner_text: Text,
    underline_size: i32,

    pub fn init(allocator: std.mem.Allocator, options: struct {
        text: []const u8,
        font_size: i32 = 20,
        color: rl.Color = .white,
        on_update: ?Callback = null,
        underline_size: i32 = 5,
        default: ?[]const u8 = null,
    }) !UnderlinedText {
        return UnderlinedText{
            .inner_text = try Text.init(allocator, .{
                .text = options.text,
                .font_size = options.font_size,
                .color = options.color,
                .on_update = options.on_update,
                .default = options.default,
            }),
            .underline_size = options.underline_size,
        };
    }

    pub fn draw(self: *const UnderlinedText, location: Location) void {
        self.inner_text.draw(location);
        const text_width = rl.measureText(self.inner_text.text.toSlice(), self.inner_text.font_size);
        const offset = @max(2, @divTrunc(self.inner_text.font_size, 20));
        const line_y = location.y() + self.inner_text.font_size - @divTrunc(self.inner_text.font_size, 5) + offset;
        rl.drawRectangle(location.x(), line_y, text_width, self.underline_size, self.inner_text.color);
    }

    pub fn update(self: *UnderlinedText) void {
        self.inner_text.update();
    }

    pub fn deinit(self: *UnderlinedText, allocator: std.mem.Allocator) void {
        self.inner_text.deinit(allocator);
    }

    pub fn resetToDefault(self: *UnderlinedText, allocator: std.mem.Allocator) !void {
        try self.inner_text.resetToDefault(allocator);
    }

    pub fn getWidth(self: *const UnderlinedText) i32 {
        return self.inner_text.getWidth();
    }

    pub fn getHeight(self: *const UnderlinedText) i32 {
        return self.inner_text.font_size + self.underline_size + @max(2, @divTrunc(self.inner_text.font_size, 20));
    }
};
