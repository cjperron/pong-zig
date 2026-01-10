const std = @import("std");
const rl = @import("raylib");
const Location = @import("../Location.zig");

color : rl.Color,
radius : i32,
thickness : i32, // grosor del circulo, si es 0 se rell
fill : bool,

const Self = @This();

pub fn init(options: struct {
	color: rl.Color = .white,
	radius: i32 = 50,
	thickness: i32 = 2,
	fill: bool = false,
}) Self {
	return Self{
		.color = options.color,
		.radius = options.radius,
		.thickness = options.thickness,
		.fill = options.fill,
	};
}

pub fn draw(self: *const Self, location: Location) void {
	if (self.fill) {
		rl.drawCircle(location.x(), location.y(), @floatFromInt(self.radius), self.color);
	} else {
		rl.drawCircleLines(location.x(), location.y(), @floatFromInt(self.radius), self.color);
	}
}
