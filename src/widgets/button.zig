const std = @import("std");
const rl = @import("raylib");
const U8StringZ = @import("../string.zig").U8StringZ;
const Callback = @import("../root.zig").Callback;
const pong_bg_color = @import("../widget.zig").pong_bg_color;


pub const Button = struct {
    label: U8StringZ,
    font_size: i32,
    color: rl.Color,
    bg_color: rl.Color,
    highlight_color: rl.Color,
    highlighted: bool = false,

    on_click: ?Callback,

    pub fn init(allocator: std.mem.Allocator, options: struct {
        label: []const u8 = "Button",
        font_size: i32 = 20,
        color: rl.Color = .white,
        bg_color: rl.Color = pong_bg_color,
        hightlight_color: rl.Color = .white,
        on_click: ?Callback = null,
    }) !Button {
        return Button{
            .label = try U8StringZ.initFromSlice(allocator, options.label),
            .font_size = options.font_size,
            .color = options.color,
            .bg_color = options.bg_color,
            .highlight_color = options.hightlight_color,
            .on_click = options.on_click,
        };
    }

    pub fn isClicked(self: *const Button, x: i32, y: i32) bool {
        const mouseX = rl.getMouseX();
        const mouseY = rl.getMouseY();
        const mousePressed = rl.isMouseButtonPressed(rl.MouseButton.left);

        return mousePressed and
            (mouseX >= x) and (mouseX <= x + self.getWidth()) and
            (mouseY >= y) and (mouseY <= y + self.getHeight());
    }

    pub fn isHovered(self: *const Button, x: i32, y: i32) bool {
        const mouseX = rl.getMouseX();
        const mouseY = rl.getMouseY();

        return (mouseX >= x) and (mouseX <= x + self.getWidth()) and
            (mouseY >= y) and (mouseY <= y + self.getHeight());
    }

    pub fn draw(self: *const Button, x: i32, y: i32) void {
        rl.drawRectangle(x, y, self.getWidth(), self.getHeight(), self.bg_color);

        const textWidth = rl.measureText(self.label.toSlice(), self.font_size);
        const textX = x + @divTrunc((self.getWidth() - textWidth), 2);
        const textY = y + @divTrunc((self.getHeight() - self.font_size), 2);

        rl.drawText(self.label.toSlice(), textX, textY, self.font_size, self.color);
        if (self.highlighted) {
            const text_width = rl.measureText(self.label.toSlice(), self.font_size);
            const offset = @max(2, @divTrunc(self.font_size, 20));
            const line_y = y + self.getHeight() + offset;
            const underline_size = @max(2, @divTrunc(self.font_size, 10));
            rl.drawRectangle(x, line_y, text_width, underline_size, self.highlight_color);
        }
    }

    pub fn update(self: *Button, x: i32, y: i32) void {
        if (self.isClicked(x, y)) {
            if (self.on_click) |callback| {
                callback.call();
            }
        }
        if (self.isHovered(x, y)) {
            self.highlight();
        } else {
            self.unhighlight();
        }
    }

    pub fn toggleHighlight(self: *Button) void {
        self.highlighted = !self.highlighted;
    }

    pub fn highlight(self: *Button) void {
        self.highlighted = true;
    }

    pub fn unhighlight(self: *Button) void {
        self.highlighted = false;
    }

    pub fn deinit(self: *Button, allocator: std.mem.Allocator) void {
        self.label.deinit(allocator);
        if (self.on_click) |callback| {
            callback.deinit();
        }
    }

    pub fn getWidth(self: *const Button) i32 {
		return rl.measureText(self.label.toSlice(), self.font_size);
	}

	pub fn getHeight(self: *const Button) i32 {
		return self.font_size;
	}
};
