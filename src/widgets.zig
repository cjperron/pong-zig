const std = @import("std");
const rl = @import("raylib");
const Callback = @import("root.zig").Callback;
pub const pong_bg_color = rl.Color{ .r = 20, .g = 20, .b = 30, .a = 255 }; // color a dedo
const U8StringZ = @import("root.zig").U8StringZ;

// ===== Layout  =====

pub const Anchor = enum {
    TopLeft,
    Top,
    TopRight,
    Left,
    Center,
    Right,
    BottomLeft,
    Bottom,
    BottomRight,
};

pub const LayoutInfo = union(enum) {
    Absolute: struct {
        x: i32 = 0,
        y: i32 = 0,
    },
    Anchored: struct {
        anchor: Anchor,
        offset_x: i32 = 0,
        offset_y: i32 = 0,
    },

    pub fn calculatePosition(self: LayoutInfo, screen_width: i32, screen_height: i32) struct { x: i32, y: i32 } {
        return switch (self) {
            .Absolute => |abs| .{ .x = abs.x, .y = abs.y },
            .Anchored => |anchored| switch (anchored.anchor) {
                .TopLeft => .{ .x = anchored.offset_x, .y = anchored.offset_y },
                .Top => .{ .x = @divFloor(screen_width, 2) + anchored.offset_x, .y = anchored.offset_y },
                .TopRight => .{ .x = screen_width - anchored.offset_x, .y = anchored.offset_y },
                .Left => .{ .x = anchored.offset_x, .y = @divFloor(screen_height, 2) + anchored.offset_y },
                .Center => .{ .x = @divFloor(screen_width, 2) + anchored.offset_x, .y = @divFloor(screen_height, 2) + anchored.offset_y },
                .Right => .{ .x = screen_width - anchored.offset_x, .y = @divFloor(screen_height, 2) + anchored.offset_y },
                .BottomLeft => .{ .x = anchored.offset_x, .y = screen_height - anchored.offset_y },
                .Bottom => .{ .x = @divFloor(screen_width, 2) + anchored.offset_x, .y = screen_height - anchored.offset_y },
                .BottomRight => .{ .x = screen_width - anchored.offset_x, .y = screen_height - anchored.offset_y },
            },
        };
    }
};

// ===== Widgets =====

pub const Widget = struct {
    x: i32,
    y: i32,
    layout_info: LayoutInfo,
    inner: WidgetInner,

    const Self = @This();

    pub fn initText(allocator: std.mem.Allocator, options: struct {
        text: []const u8 = "Text",
        font_size: i32 = 20,
        color: rl.Color = rl.Color.white,
        on_update: ?Callback = null,
        layout_info: LayoutInfo,
    }) !Self {
        const pos = options.layout_info.calculatePosition(rl.getScreenWidth(), rl.getScreenHeight());
        return Self{
            .x = pos.x,
            .y = pos.y,
            .layout_info = options.layout_info,
            .inner = .{ .text = try Text.init(allocator, .{
                .text = options.text,
                .font_size = options.font_size,
                .color = options.color,
                .on_update = options.on_update,
            }) },
        };
    }

    pub fn initUnderlinedText(allocator: std.mem.Allocator, options: struct {
        text: []const u8 = "Underlined Text",
        font_size: i32 = 20,
        color: rl.Color = rl.Color.white,
        on_update: ?Callback = null,
        underline_size: i32 = 5,
        layout_info: LayoutInfo,
    }) !Self {
        const pos = options.layout_info.calculatePosition(rl.getScreenWidth(), rl.getScreenHeight());
        return Self{
            .x = pos.x,
            .y = pos.y,
            .layout_info = options.layout_info,
            .inner = .{ .underlined_text = try UnderlinedText.init(allocator, .{
                .text = options.text,
                .font_size = options.font_size,
                .color = options.color,
                .on_update = options.on_update,
                .underline_size = options.underline_size,
            }) },
        };
    }

    pub fn initButton(allocator: std.mem.Allocator, options: struct {
        label: []const u8 = "Button",
        font_size: i32 = 20,
        color: rl.Color = .white,
        bg_color: rl.Color = pong_bg_color,
        on_click: ?Callback = null,
        layout_info: LayoutInfo,
    }) !Self {
        const pos = options.layout_info.calculatePosition(rl.getScreenWidth(), rl.getScreenHeight());
        return Self{
            .x = pos.x,
            .y = pos.y,
            .layout_info = options.layout_info,
            .inner = .{ .button = try Button.init(allocator, .{
                .label = options.label,
                .font_size = options.font_size,
                .color = options.color,
                .bg_color = options.bg_color,
                .on_click = options.on_click,
            }) },
        };
    }

    pub fn initWidgetGroup(options: struct {
        widgets: std.ArrayList(Widget),
        spacing: i32,
        orientation: Orientation = .Vertical,
        layout_info: LayoutInfo,
    }) !Self {
        const pos = options.layout_info.calculatePosition(rl.getScreenWidth(), rl.getScreenHeight());
        var widget = Self{
            .x = pos.x,
            .y = pos.y,
            .layout_info = options.layout_info,
            .inner = .{ .button_group = try WidgetGroup.init(.{
                .buttons = options.widgets,
                .spacing = options.spacing,
                .orientation = options.orientation,
            }) },
        };
        // Posicionar botones inicialmente
        widget.inner.button_group.repositionButtons(widget.x, widget.y);
        return widget;
    }

    pub fn draw(self: *const Self) void {
        self.inner.draw(self.x, self.y);
    }

    pub fn update(self: *Self) void {
        self.inner.update(self.x, self.y);
    }

    pub fn deinit(self: *Self, allocator: std.mem.Allocator) void {
        self.inner.deinit(allocator);
    }

    pub fn reposition(self: *Self) void {
        const screen_width = rl.getScreenWidth();
        const screen_height = rl.getScreenHeight();
        const pos = self.layout_info.calculatePosition(screen_width, screen_height);
        self.x = pos.x;
        self.y = pos.y;

        // Si es un ButtonGroup, también reposicionar sus botones internos
        if (self.inner == .button_group) {
            self.inner.button_group.repositionButtons(self.x, self.y);
        }
    }
};

pub const WidgetInner = union(enum) {
    text: Text,
    underlined_text: UnderlinedText,
    button: Button,
    button_group: WidgetGroup,
    _,

    const Self = @This();

    pub fn draw(self: *const Self, x: i32, y: i32) void {
        switch (self.*) {
            .text => |t| t.draw(x, y),
            .underlined_text => |ut| ut.draw(x, y),
            .button => |b| b.draw(x, y),
            .button_group => |bg| bg.draw(x, y),
            else => {},
        }
    }

    pub fn update(self: *Self, x: i32, y: i32) void {
        switch (self.*) {
            .text => |*t| t.update(),
            .underlined_text => |*ut| ut.update(),
            .button => |*b| b.update(x, y),
            .button_group => |*bg| bg.update(x, y),
            else => {},
        }
    }

    pub fn deinit(self: *Self, allocator: std.mem.Allocator) void {
        switch (self.*) {
            .button_group => |*bg| bg.deinit(allocator),
            .text => |*t| t.deinit(allocator),
            .underlined_text => |*ut| ut.deinit(allocator),
            .button => |*b| b.deinit(allocator),
            else => {},
        }
    }
};

pub const Text = struct {
    text: U8StringZ,
    font_size: i32,
    color: rl.Color,
    on_update: ?Callback,

    pub fn init(
        allocator: std.mem.Allocator,
        options: struct {
            text: []const u8,
            font_size: i32 = 20,
            color: rl.Color = rl.Color.white,
            on_update: ?Callback = null,
        },
    ) !Text {
        return Text{
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

    pub fn draw(self: *const Text, x: i32, y: i32) void {
        rl.drawText(self.text.toSlice(), x, y, self.font_size, self.color);
    }

    pub fn deinit(self: *Text, allocator: std.mem.Allocator) void {
        self.text.deinit(allocator);
    }
};

pub const UnderlinedText = struct {
    inner_text: Text,
    underline_size: i32,

    pub fn init(allocator: std.mem.Allocator, options: struct {
        text: []const u8,
        font_size: i32 = 20,
        color: rl.Color = rl.Color.white,
        on_update: ?Callback = null,
        underline_size: i32 = 5,
    }) !UnderlinedText {
        return UnderlinedText{
            .inner_text = try Text.init(allocator, .{
                .text = options.text,
                .font_size = options.font_size,
                .color = options.color,
                .on_update = options.on_update,
            }),
            .underline_size = options.underline_size,
        };
    }

    pub fn draw(self: *const UnderlinedText, x: i32, y: i32) void {
        self.inner_text.draw(x, y);
        const text_width = rl.measureText(self.inner_text.text.toSlice(), self.inner_text.font_size);
        const offset = @max(2, @divTrunc(self.inner_text.font_size, 20));
        const line_y = y + self.inner_text.font_size - @divTrunc(self.inner_text.font_size, 5) + offset;
        rl.drawRectangle(x, line_y, text_width, self.underline_size, self.inner_text.color);
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
        on_click: ?Callback = null,
    }) !Button {
        var button = Button{
            .label = try U8StringZ.initFromSlice(allocator, options.label),
            .font_size = options.font_size,
            .color = options.color,
            .bg_color = options.bg_color,
            .highlight_color = options.hightlight_color,
            .width = undefined,
            .height = options.font_size,
            .on_click = options.on_click,
        };
        errdefer button.label.deinit(allocator);

        button.width = rl.measureText(button.label.toSlice(), options.font_size);
        return button;
    }

    pub fn isClicked(self: *const Button, x: i32, y: i32) bool {
        const mouseX = rl.getMouseX();
        const mouseY = rl.getMouseY();
        const mousePressed = rl.isMouseButtonPressed(rl.MouseButton.left);

        return mousePressed and
            (mouseX >= x) and (mouseX <= x + self.width) and
            (mouseY >= y) and (mouseY <= y + self.height);
    }

    pub fn isHovered(self: *const Button, x: i32, y: i32) bool {
        const mouseX = rl.getMouseX();
        const mouseY = rl.getMouseY();

        return (mouseX >= x) and (mouseX <= x + self.width) and
            (mouseY >= y) and (mouseY <= y + self.height);
    }

    pub fn draw(self: *const Button, x: i32, y: i32) void {
        rl.drawRectangle(x, y, self.width, self.height, self.bg_color);

        const textWidth = rl.measureText(self.label.toSlice(), self.font_size);
        const textX = x + @divTrunc((self.width - textWidth), 2);
        const textY = y + @divTrunc((self.height - self.font_size), 2);

        rl.drawText(self.label.toSlice(), textX, textY, self.font_size, self.color);
        if (self.highlighted) {
            const text_width = rl.measureText(self.label.toSlice(), self.font_size);
            const offset = @max(2, @divTrunc(self.font_size, 20));
            const line_y = y + self.height + offset;
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
};

pub const Orientation = enum {
    Vertical,
    Horizontal,
};

pub const WidgetGroup = struct {
    buttons: std.ArrayList(Widget),
    spacing: i32,
    orientation: Orientation,

    const Self = @This();

    pub fn init(options: struct {
        buttons: std.ArrayList(Widget),
        spacing: i32,
        orientation: Orientation = .Vertical,
    }) !Self {
        return Self{
            .buttons = options.buttons,
            .spacing = options.spacing,
            .orientation = options.orientation,
        };
    }

    pub fn repositionButtons(self: *Self, base_x: i32, base_y: i32) void {
        var current_y = base_y;
        var current_x = base_x;

        for (self.buttons.items) |*widget| {
            widget.x = current_x;
            widget.y = current_y;

            // Obtener dimensiones del botón para calcular el siguiente offset
            const height = switch (widget.inner) {
                .button => |b| b.height,
                else => 0,
            };
            const width = switch (widget.inner) {
                .button => |b| b.width,
                else => 0,
            };

            switch (self.orientation) {
                .Vertical => current_y += height + self.spacing,
                .Horizontal => current_x += width + self.spacing,
            }
        }
    }

    pub fn update(self: *Self, x: i32, y: i32) void {
        _ = x;
        _ = y;
        for (self.buttons.items) |*widget| {
            widget.update();
        }
    }

    pub fn draw(self: *const Self, x: i32, y: i32) void {
        _ = x;
        _ = y;
        for (self.buttons.items) |*widget| {
            widget.draw();
        }
    }

    pub fn deinit(self: *Self, allocator: std.mem.Allocator) void {
        for (self.buttons.items) |*widget| {
            widget.deinit(allocator);
        }
        self.buttons.deinit(allocator);
    }
};
