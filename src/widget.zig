const std = @import("std");
const rl = @import("raylib");
const Callback = @import("root.zig").Callback;
pub const pong_bg_color = rl.Color{ .r = 20, .g = 20, .b = 30, .a = 255 }; // color a dedo
const U8StringZ = @import("root.zig").U8StringZ;

// Importar widgets individuales
const Text = @import("widgets/text.zig").Text;
const UnderlinedText = @import("widgets/underlined_text.zig").UnderlinedText;
const Button = @import("widgets/button.zig").Button;

const WidgetGroup = @import("widgets/widget_group.zig").WidgetGroup;
const Orientation = @import("widgets/widget_group.zig").Orientation;

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
        default: ?[]const u8 = null,
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
                .default = options.default,
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
        default: ?[]const u8 = null,
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
                .default = options.default,
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

    pub fn initWidgetGroup(
        options: struct {
            widgets: std.ArrayList(Widget),
            spacing: i32 = 5,
            orientation: Orientation = .Vertical,
            layout_info: LayoutInfo = .{ .Absolute = .{} }, // def: (0,0)
        },
    ) !Self {
        const pos = options.layout_info.calculatePosition(rl.getScreenWidth(), rl.getScreenHeight());
        var widget = Self{
            .x = pos.x,
            .y = pos.y,
            .layout_info = options.layout_info,
            .inner = .{ .widget_group = try WidgetGroup.init(.{
                .buttons = options.widgets,
                .spacing = options.spacing,
                .orientation = options.orientation,
            }) },
        };
        // Posicionar botones inicialmente
        widget.inner.widget_group.repositionWidgets(widget.x, widget.y);
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
        if (self.inner == .widget_group) {
            self.inner.widget_group.repositionWidgets(self.x, self.y);
        }
    }
};

pub const WidgetInner = union(enum) {
    text: Text,
    underlined_text: UnderlinedText,
    button: Button,
    widget_group: WidgetGroup,
    _,

    const Self = @This();

    pub fn draw(self: *const Self, x: i32, y: i32) void {
        switch (self.*) {
            .text => |t| t.draw(x, y),
            .underlined_text => |ut| ut.draw(x, y),
            .button => |b| b.draw(x, y),
            .widget_group => |bg| bg.draw(),
            else => {},
        }
    }

    pub fn update(self: *Self, x: i32, y: i32) void {
        switch (self.*) {
            .text => |*t| t.update(),
            .underlined_text => |*ut| ut.update(),
            .button => |*b| b.update(x, y),
            .widget_group => |*bg| bg.update(),
            else => {},
        }
    }

    pub fn deinit(self: *Self, allocator: std.mem.Allocator) void {
        switch (self.*) {
            .widget_group => |*bg| bg.deinit(allocator),
            .text => |*t| t.deinit(allocator),
            .underlined_text => |*ut| ut.deinit(allocator),
            .button => |*b| b.deinit(allocator),
            else => {},
        }
    }
};
