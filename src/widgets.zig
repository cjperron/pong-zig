const std = @import("std");
const rl = @import("raylib");
const Callback = @import("root.zig").Callback;
pub const pong_bg_color = rl.Color{ .r = 20, .g = 20, .b = 30, .a = 255 }; // color a dedo
const U8StringZ = @import("root.zig").U8StringZ;
// ===== Widgets =====

pub const Widget = union(enum) {
    text: Text,
    underlined_text: UnderlinedText,
    button: Button,
    button_group: ButtonGroup,
    _,
    // Agregar más widgets según sea necesario
    const Self = @This();

    pub fn initText(allocator: std.mem.Allocator, options: struct {
        x: i32 = 0,
        y: i32 = 0,
        text: []const u8 = "Text",
        font_size: i32 = 20,
        color: rl.Color = rl.Color.white,
        on_update: ?Callback = null,
    }) !Self {
        return Self{ .text = try Text.init(allocator, .{
            .x = options.x,
            .y = options.y,
            .text = options.text,
            .font_size = options.font_size,
            .color = options.color,
            .on_update = options.on_update,
        }) };
    }

    pub fn initUnderlinedText(allocator: std.mem.Allocator, options: struct {
        x: i32 = 0,
        y: i32 = 0,
        text: []const u8 = "Underlined Text",
        font_size: i32 = 20,
        color: rl.Color = rl.Color.white,
        on_update: ?Callback = null,
        underline_size: i32 = 5,
    }) !Self {
        return Self{ .underlined_text = try UnderlinedText.init(allocator, .{
            .x = options.x,
            .y = options.y,
            .text = options.text,
            .font_size = options.font_size,
            .color = options.color,
            .on_update = options.on_update,
            .underline_size = options.underline_size,
        }) };
    }

    pub fn initButton(allocator: std.mem.Allocator, options: struct {
        label: []const u8 = "Button",
        font_size: i32 = 20,
        color: rl.Color = .white,
        bg_color: rl.Color = pong_bg_color,
        x: i32 = 0,
        y: i32 = 0,
        on_click: ?Callback = null,
    }) !Self {
        return Self{ .button = try Button.init(allocator, .{
            .label = options.label,
            .font_size = options.font_size,
            .color = options.color,
            .bg_color = options.bg_color,
            .x = options.x,
            .y = options.y,
            .on_click = options.on_click,
        }) };
    }

    pub fn initButtonGroup(options: struct {
        buttons: std.ArrayList(Button),
        x: i32,
        y: i32,
        spacing: i32,
        orientation: Orientation = .Vertical,
    }) Self {
        return Self{ .button_group = ButtonGroup.init(.{
            .buttons = options.buttons,
            .x = options.x,
            .y = options.y,
            .spacing = options.spacing,
            .orientation = options.orientation,
        }) };
    }

    pub fn draw(self: *const Self) void {
        switch (self.*) {
            .text => |t| t.draw(),
            .underlined_text => |ut| ut.draw(),
            .button => |b| b.draw(),
            .button_group => |ms| ms.draw(),
            else => {
            // This should only be reached if widget inner type does not have draw impl
            // @compileLog("Warning: Widget type has no draw implementation", @TypeOf(self.*));
            },
        }
    }

    pub fn update(self: *Self) void {
        switch (self.*) {
            .text => |*t| t.update(),
            .underlined_text => |*ut| ut.update(),
            .button => |*b| b.update(),
            .button_group => |*ms| ms.update(),
            else => {
                // @compileLog("Warning: Widget type has no update implementation", @TypeOf(self.*));
            },
        }
    }

    pub fn deinit(self: *Self, allocator: std.mem.Allocator) void {
        switch (self.*) {
            .button_group => |*ms| ms.deinit(allocator),
            .text => |*t| t.deinit(allocator),
            .underlined_text => |*ut| ut.deinit(allocator),
            .button => |*b| b.deinit(allocator),
            else => {
                // @compileLog("Warning: Widget type has no deinit implementation", @TypeOf(self.*));
            },
        }
    }
};

pub const Text = struct {
    x: i32,
    y: i32,
    text: U8StringZ,
    font_size: i32,
    color: rl.Color,
    on_update: ?Callback,

    pub fn init(
        allocator: std.mem.Allocator,
        options: struct {
            x: i32,
            y: i32,
            text: []const u8,
            font_size: i32 = 20,
            color: rl.Color = rl.Color.white,
            on_update: ?Callback = null,
        },
    ) !Text {
        return Text{
            .x = options.x,
            .y = options.y,
            .text = try U8StringZ.initFromSlice(allocator, options.text),
            .font_size = options.font_size,
            .color = options.color,
            .on_update = options.on_update,
        };
    }

    pub fn update(self: *Text) void {
        if (self.on_update) |callback| {
            callback.call();
        }
    }

    pub fn draw(self: *const Text) void {
        rl.drawText(self.text.toSlice(), self.x, self.y, self.font_size, self.color);
    }

    pub fn deinit(self: *Text, allocator: std.mem.Allocator) void {
        self.text.deinit(allocator);
    }
};

pub const UnderlinedText = struct {
    inner_text: Text,
    underline_size: i32,

    pub fn init(allocator: std.mem.Allocator, options: struct {
        x: i32,
        y: i32,
        text: []const u8,
        font_size: i32 = 20,
        color: rl.Color = rl.Color.white,
        on_update: ?Callback = null,
        underline_size: i32 = 5,
    }) !UnderlinedText {
        return UnderlinedText{
            .inner_text = try Text.init(allocator, .{
                .x = options.x,
                .y = options.y,
                .text = options.text,
                .font_size = options.font_size,
                .color = options.color,
                .on_update = options.on_update,
            }),
            .underline_size = options.underline_size,
        };
    }

    pub fn draw(self: *const UnderlinedText) void {
        self.inner_text.draw();
        const text_width = rl.measureText(self.inner_text.text.toSlice(), self.inner_text.font_size);
        const offset = @max(2, @divTrunc(self.inner_text.font_size, 20));
        const line_y = self.inner_text.y + self.inner_text.font_size - @divTrunc(self.inner_text.font_size, 5) + offset;
        rl.drawRectangle(self.inner_text.x, line_y, text_width, self.underline_size, self.inner_text.color);
    }

    pub fn update(self: *UnderlinedText) void {
        self.inner_text.update();
    }

    pub fn deinit(self: *UnderlinedText, allocator: std.mem.Allocator) void {
        self.inner_text.deinit(allocator);
    }
};

pub const Button = struct {
    label: U8StringZ,
    font_size: i32,
    color: rl.Color,
    bg_color: rl.Color,
    x: i32,
    y: i32,
    width: i32,
    height: i32,
    highlight_color: rl.Color,
    highlighted: bool = false,

    on_click: ?Callback,

    pub fn init(allocator: std.mem.Allocator, options: struct {
        label: []const u8 = "Button",
        font_size: i32 = 20,
        color: rl.Color = .white,
        bg_color: rl.Color = pong_bg_color,
        hightlight_color: rl.Color = .white,
        x: i32 = 0,
        y: i32 = 0,
        on_click: ?Callback = null,
    }) !Button {
        var button = Button{
            .label = try U8StringZ.initFromSlice(allocator, options.label),
            .font_size = options.font_size,
            .color = options.color,
            .bg_color = options.bg_color,
            .highlight_color = options.hightlight_color,
            .x = options.x,
            .y = options.y,
            .width = undefined,
            .height = options.font_size,
            .on_click = options.on_click,
        };
        errdefer button.label.deinit(allocator); // por las dudas...

        button.width = rl.measureText(button.label.toSlice(), options.font_size);
        return button;
    }

    pub fn isClicked(self: *const Button) bool {
        const mouseX = rl.getMouseX();
        const mouseY = rl.getMouseY();
        const mousePressed = rl.isMouseButtonPressed(rl.MouseButton.left);

        return mousePressed and
            (mouseX >= self.x) and (mouseX <= self.x + self.width) and
            (mouseY >= self.y) and (mouseY <= self.y + self.height);
    }

    pub fn isHovered(self: *const Button) bool {
        const mouseX = rl.getMouseX();
        const mouseY = rl.getMouseY();

        return (mouseX >= self.x) and (mouseX <= self.x + self.width) and
            (mouseY >= self.y) and (mouseY <= self.y + self.height);
    }

    pub fn draw(self: *const Button) void {
        rl.drawRectangle(self.x, self.y, self.width, self.height, self.bg_color);

        const textWidth = rl.measureText(self.label.toSlice(), self.font_size);
        const textX = self.x + @divTrunc((self.width - textWidth), 2);
        const textY = self.y + @divTrunc((self.height - self.font_size), 2);

        rl.drawText(self.label.toSlice(), textX, textY, self.font_size, self.color);
        if (self.highlighted) {
            const text_width = rl.measureText(self.label.toSlice(), self.font_size);
            const offset = @max(2, @divTrunc(self.font_size, 20));
            const line_y = self.y + self.height + offset;
            const underline_size = @max(2, @divTrunc(self.font_size, 10));
            rl.drawRectangle(self.x, line_y, text_width, underline_size, self.highlight_color);
        }
    }

    pub fn update(self: *Button) void {
        if (self.isClicked()) {
            if (self.on_click) |callback| {
                callback.call();
            }
        }
        if (self.isHovered()) {
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
};

pub const Orientation = enum {
    Vertical,
    Horizontal,
};

pub const ButtonGroup = struct {
    buttons: std.ArrayList(Button),
    x: i32,
    y: i32,
    spacing: i32,
    orientation: Orientation,

    pub fn init(options: struct {
        buttons: std.ArrayList(Button),
        x: i32,
        y: i32,
        spacing: i32,
        orientation: Orientation = .Vertical,
    }) ButtonGroup {
        var current_y = options.y;
        var current_x = options.x;

        for (options.buttons.items) |*button| {
            button.x = current_x;
            button.y = current_y;

            switch (options.orientation) {
                .Vertical => current_y += button.height + options.spacing,
                .Horizontal => current_x += button.width + options.spacing,
            }
        }

        return ButtonGroup{
            .buttons = options.buttons,
            .x = options.x,
            .y = options.y,
            .spacing = options.spacing,
            .orientation = options.orientation,
        };
    }

    pub fn update(self: *ButtonGroup) void {
        for (self.buttons.items) |*button| {
            button.update();
        }
    }

    pub fn draw(self: *const ButtonGroup) void {
        for (self.buttons.items) |button| {
            button.draw();
        }
    }

    pub fn deinit(self: *ButtonGroup, allocator: std.mem.Allocator) void {
        for (self.buttons.items) |*button| {
            button.deinit(allocator);
        }
        self.buttons.deinit(allocator);
    }
};
