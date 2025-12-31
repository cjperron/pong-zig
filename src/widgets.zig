const std = @import("std");
const rl = @import("raylib");

pub const Text = struct {
	x: i32,
	y: i32,
	text: []const u8,
	font_size: i32,
	color: rl.Color,
	updateable: bool,

	// TODO: init()

	pub fn update(self: *Text) void {
		// Placeholder for update logic if needed in the future
		if (self.updateable) {
			// Implement any dynamic update logic here
		}
	}

	pub fn draw(self: Text) void {
		rl.drawText(self.text, self.x, self.y, self.font_size, self.color);
	}
};

pub const UnderlinedText = struct {
	text: []const u8,
	font_size: i32,
	color: rl.Color,
	updateable: bool,

	// TODO : init()

	pub fn update(self: *UnderlinedText) void {
		// Placeholder for update logic if needed in the future
		if (self.updateable) {
			// Implement any dynamic update logic here
		}
	}


	pub fn draw(self: UnderlinedText, x: i32, y: i32) void {
		// Draw the text
		rl.drawText(self.text, x, y, self.font_size, self.color);

		// Calculate the width of the text for underlining
		const textWidth = rl.measureText(self.text, self.font_size);
		const underlineY = y + self.font_size + 5; // 5 pixels below the text

		// Draw the underline
		rl.drawLine(x, underlineY, x + textWidth, underlineY, self.color);
	}
};



pub const Button = struct {
	label: []const u8,
	font_size: i32,
	color: rl.Color,
	bg_color: rl.Color,
	x: i32,
	y: i32,
	width: i32,
	height: i32,

	action: fn() void,

	// TODO: init()

	pub fn isClicked(self: Button) bool {
		const mouseX = rl.getMouseX();
		const mouseY = rl.getMouseY();
		const mousePressed = rl.isMouseButtonPressed(rl.MOUSE_LEFT_BUTTON);

		return mousePressed and
			(mouseX >= self.x) and (mouseX <= self.x + self.width) and
			(mouseY >= self.y) and (mouseY <= self.y + self.height);
	}

	pub fn draw(self: Button) void {
		// Draw button background
		rl.drawRectangle(self.x, self.y, self.width, self.height, self.bg_color);

		// Calculate text position to center it in the button
		const textWidth = rl.measureText(self.label, self.font_size);
		const textX = self.x + (self.width - textWidth) / 2;
		const textY = self.y + (self.height - self.font_size) / 2;

		// Draw button label
		rl.drawText(self.label, textX, textY, self.font_size, self.color);
	}
};

/// Ayudita para tener un array de botones con layout vertical u horizontal.
pub const MenuSelection = struct {
	buttons: []Button,
	selected_index: usize,


	// TODO: init()

	pub fn update(self: *MenuSelection) void {
		for (self.buttons, 0..) |*button, index| {
			if (button.isClicked()) {
				self.selected_index = index;
				button.action();
			}
		}
	}

	pub fn draw(self: MenuSelection) void {
		for (self.buttons) |button| {
			button.draw();
		}
	}
};
