const std = @import("std");
const rl = @import("raylib");
const config = @import("root.zig").display.config;
const Callback = @import("root.zig").Callback;

// ===== Widgets =====

pub const Widget = union(enum) {
    text: Text,
    underlined_text: UnderlinedText,
    button: Button,
    menu_selection: MenuSelection,

    pub fn initText(options: struct {
        x: i32,
        y: i32,
        text: [:0]const u8,
        font_size: i32 = 20,
        color: rl.Color = rl.Color.white,
        on_update: ?Callback = null,
    }) Widget {
        return Widget{ .text = Text.init(.{
            .x = options.x,
            .y = options.y,
            .text = options.text,
            .font_size = options.font_size,
            .color = options.color,
            .on_update = options.on_update,
        }) };
    }

    pub fn initUnderlinedText(options: struct {
        x: i32,
        y: i32,
        text: [:0]const u8,
        font_size: i32 = 20,
        color: rl.Color = rl.Color.white,
        on_update: ?Callback = null,
        underline_size: i32 = 5,
    }) Widget {
        return Widget{ .underlined_text = UnderlinedText.init(.{ .inner_text = Text.init(.{
            .x = options.x,
            .y = options.y,
            .text = options.text,
            .font_size = options.font_size,
            .color = options.color,
            .on_update = options.on_update,
        }), .underline_size = options.underline_size }) };
    }

    pub fn initButton(options: struct {
        label: [:0]const u8 = "Default label",
        font_size: i32 = 20,
        color: rl.Color = .white,
        bg_color: rl.Color = .black,
        x: i32 = 0,
        y: i32 = 0,
        on_click: ?Callback = null,
    }) Widget {
        return Widget{ .button = Button.init(.{
            .label = options.label,
            .font_size = options.font_size,
            .color = options.color,
            .bg_color = options.bg_color,
            .x = options.x,
            .y = options.y,
            .on_click = options.on_click,
        }) };
    }

    pub fn initMenuSelection(options: struct {
        buttons: std.ArrayList(Button),
        x: i32,
        y: i32,
        spacing: i32,
        selected_index: usize = 0,
        orientation: Orientation = .Vertical,
    }) Widget {
        return Widget{ .menu_selection = MenuSelection.init(.{
            .buttons = options.buttons,
            .selected_index = options.selected_index,
            .x = options.x,
            .y = options.y,
            .spacing = options.spacing,
            .orientation = options.orientation,
        }) };
    }

    pub fn draw(self: @This()) void {
        switch (self) {
            .text => |t| t.draw(),
            .underlined_text => |ut| ut.draw(),
            .button => |b| b.draw(),
            .menu_selection => |ms| ms.draw(),
        }
    }

    pub fn update(self: *@This()) void {
        switch (self.*) {
            .text => |*t| t.update(),
            .underlined_text => |*ut| ut.update(),
            .button => |*b| b.update(),
            .menu_selection => |*ms| ms.update(),
        }
    }

    pub fn deinit(self: *@This(), allocator: std.mem.Allocator) void {
        switch (self.*) {
            .menu_selection => |*ms| ms.deinit(allocator),
            else => {},
        }
    }
};

pub const Text = struct {
    x: i32,
    y: i32,
    text: [:0]const u8,
    font_size: i32,
    color: rl.Color,
    on_update: ?Callback,

    pub fn init(
        options: struct {
            x: i32,
            y: i32,
            text: [:0]const u8,
            font_size: i32 = 20,
            color: rl.Color = rl.Color.white,
            on_update: ?Callback = null,
        },
    ) Text {
        return Text{
            .x = options.x,
            .y = options.y,
            .text = options.text,
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
        rl.drawText(self.text, self.x, self.y, self.font_size, self.color);
    }
};

pub const UnderlinedText = struct {
    inner_text: Text,
    underline_size: i32,

    pub fn init(options: struct { inner_text: Text, underline_size: i32 = 5 }) UnderlinedText {
        return UnderlinedText{ .inner_text = options.inner_text, .underline_size = options.underline_size };
    }

    pub fn draw(self: *const UnderlinedText) void {
        self.inner_text.draw();
        const text_width = rl.measureText(self.inner_text.text, self.inner_text.font_size);
        const offset = @max(2, @divTrunc(self.inner_text.font_size, 20));
        const line_y = self.inner_text.y + self.inner_text.font_size - @divTrunc(self.inner_text.font_size, 5) + offset;
        rl.drawRectangle(self.inner_text.x, line_y, text_width, self.underline_size, self.inner_text.color);
    }

    pub fn update(self: *UnderlinedText) void {
        self.inner_text.update();
    }
};

pub const Button = struct {
    label: [:0]const u8,
    font_size: i32,
    color: rl.Color,
    bg_color: rl.Color,
    x: i32,
    y: i32,
    width: i32,
    height: i32,
    highlight_color: rl.Color = .white,
    highlighted: bool = false,

    on_click: ?Callback,

    pub fn init(options: struct {
        label: [:0]const u8 = "Default label",
        font_size: i32 = 20,
        color: rl.Color = .white,
        bg_color: rl.Color = config.pong_bg_color,
        x: i32 = 0,
        y: i32 = 0,
        on_click: ?Callback = null,
    }) Button {
        return Button{
            .label = options.label,
            .font_size = options.font_size,
            .color = options.color,
            .bg_color = options.bg_color,
            .x = options.x,
            .y = options.y,
            .width = rl.measureText(options.label, options.font_size),
            .height = options.font_size,
            .on_click = options.on_click,
        };
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

        const textWidth = rl.measureText(self.label, self.font_size);
        const textX = self.x + @divTrunc((self.width - textWidth), 2);
        const textY = self.y + @divTrunc((self.height - self.font_size), 2);

        rl.drawText(self.label, textX, textY, self.font_size, self.color);
        if (self.highlighted) {
            const text_width = rl.measureText(self.label, self.font_size);
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
};

pub const Orientation = enum {
    Vertical,
    Horizontal,
};

pub const MenuSelection = struct {
    buttons: std.ArrayList(Button),
    selected_index: usize,
    x: i32,
    y: i32,
    spacing: i32,
    orientation: Orientation,

    pub fn init(options: struct {
        buttons: std.ArrayList(Button),
        x: i32,
        y: i32,
        spacing: i32,
        selected_index: usize = 0,
        orientation: Orientation = .Vertical,
    }) MenuSelection {
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

        return MenuSelection{
            .buttons = options.buttons,
            .selected_index = options.selected_index,
            .x = options.x,
            .y = options.y,
            .spacing = options.spacing,
            .orientation = options.orientation,
        };
    }

    pub fn update(self: *MenuSelection) void {
        for (self.buttons.items) |*button| {
            button.update();
        }
    }

    pub fn draw(self: *const MenuSelection) void {
        for (self.buttons.items) |button| {
            button.draw();
        }
    }

    pub fn deinit(self: *MenuSelection, allocator: std.mem.Allocator) void {
        for (self.buttons.items) |*button| {
            if (button.on_click) |callback| {
                callback.deinit();
            }
        }
        self.buttons.deinit(allocator);
    }
};
