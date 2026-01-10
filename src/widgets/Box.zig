const std = @import("std");
const rl = @import("raylib");
const Location = @import("../Location.zig");
const pong_bg_color = @import("../widget.zig").pong_bg_color;

// Campos
color: rl.Color,
width: i32,
height: i32,
fill: bool,

const Self = @This();

pub fn init(options: struct {
	color: rl.Color = pong_bg_color,
	width: i32 = 100,
	height: i32 = 100,
	fill: bool = false,
}) Self {
	return Self{
		.color = options.color,
		.width = options.width,
		.height = options.height,
		.fill = options.fill,
	};
}

pub fn draw(self: *const Self, location: Location) void {
	if (self.fill) {
		rl.drawRectangle(location.x(), location.y(), self.width, self.height, self.color);
	} else {
		rl.drawRectangleLines(location.x(), location.y(), self.width, self.height, self.color);
	}
}

pub fn getWidth(self: *const Self) i32 {
	return self.width;
}

pub fn getHeight(self: *const Self) i32 {
	return self.height;
}
