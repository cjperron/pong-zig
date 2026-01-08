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

    /// Calcula la posición considerando las dimensiones del widget
    pub fn calculatePosition(self: LayoutInfo, screen_width: i32, screen_height: i32, widget_width: i32, widget_height: i32) struct { x: i32, y: i32 } {
        switch (self) {
            .Absolute => |abs| return .{ .x = abs.x, .y = abs.y },
            .Anchored => |anchored| {
                const base_pos : struct {x: i32, y:i32} = switch (anchored.anchor) {
                    .TopLeft => .{ .x = 0, .y = 0 },
                    .Top => .{ .x = @divFloor(screen_width, 2) - @divFloor(widget_width, 2), .y = 0 },
                    .TopRight => .{ .x = screen_width - widget_width, .y = 0 },
                    .Left => .{ .x = 0, .y = @divFloor(screen_height, 2) - @divFloor(widget_height, 2) },
                    .Center => .{ .x = @divFloor(screen_width, 2) - @divFloor(widget_width, 2), .y = @divFloor(screen_height, 2) - @divFloor(widget_height, 2) },
                    .Right => .{ .x = screen_width - widget_width, .y = @divFloor(screen_height, 2) - @divFloor(widget_height, 2) },
                    .BottomLeft => .{ .x = 0, .y = screen_height - widget_height },
                    .Bottom => .{ .x = @divFloor(screen_width, 2) - @divFloor(widget_width, 2), .y = screen_height - widget_height },
                    .BottomRight => .{ .x = screen_width - widget_width, .y = screen_height - widget_height },
                };
                return .{ .x = base_pos.x + anchored.offset_x, .y = base_pos.y + anchored.offset_y };
            },
        }
    }
};

// ===== Widget =====

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
        var wget = Self{
            .x = undefined,
            .y = undefined,
            .layout_info = options.layout_info,
            .inner = .{ .text = try Text.init(allocator, .{
                .text = options.text,
                .font_size = options.font_size,
                .color = options.color,
                .on_update = options.on_update,
                .default = options.default,
            }) },
        };
        const pos = options.layout_info.calculatePosition(rl.getScreenWidth(), rl.getScreenHeight(), wget.getWidth(), wget.getHeight());
        wget.x = pos.x;
        wget.y = pos.y;
        return wget;
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
        var wget = Self{
            .x = undefined,
            .y = undefined,
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
        const pos = options.layout_info.calculatePosition(rl.getScreenWidth(), rl.getScreenHeight(), wget.getWidth(), wget.getHeight());
        wget.x = pos.x;
        wget.y = pos.y;
        return wget;
    }

    pub fn initButton(allocator: std.mem.Allocator, options: struct {
        label: []const u8 = "Button",
        font_size: i32 = 20,
        color: rl.Color = .white,
        bg_color: rl.Color = pong_bg_color,
        on_click: ?Callback = null,
        layout_info: LayoutInfo,
    }) !Self {
        var wget = Self{
            .x = undefined,
            .y = undefined,
            .layout_info = options.layout_info,
            .inner = .{ .button = try Button.init(allocator, .{
                .label = options.label,
                .font_size = options.font_size,
                .color = options.color,
                .bg_color = options.bg_color,
                .on_click = options.on_click,
            }) },
        };
        const pos = options.layout_info.calculatePosition(rl.getScreenWidth(), rl.getScreenHeight(), wget.getWidth(), wget.getHeight());
        wget.x = pos.x;
        wget.y = pos.y;
        return wget;
    }

    pub fn initWidgetGroup(
        options: struct {
            widgets: std.ArrayList(Widget),
            spacing: i32 = 5,
            orientation: Orientation = .Vertical,
            layout_info: LayoutInfo = .{ .Absolute = .{} }, // def: (0,0)
        },
    ) !Self {
        var wget = Self{
            .x = undefined,
            .y = undefined,
            .layout_info = options.layout_info,
            .inner = .{ .widget_group = try WidgetGroup.init(.{
                .buttons = options.widgets,
                .spacing = options.spacing,
                .orientation = options.orientation,
            }) },
        };
        const pos = options.layout_info.calculatePosition(rl.getScreenWidth(), rl.getScreenHeight(), wget.getWidth(), wget.getHeight());
        wget.x = pos.x;
        wget.y = pos.y;
        // Posicionar botones inicialmente
        wget.inner.widget_group.repositionWidgets(wget.x, wget.y);
        return wget;
    }

    pub fn reposition(self: *Self) void {
        const screen_width = rl.getScreenWidth();
        const screen_height = rl.getScreenHeight();
        const pos = self.layout_info.calculatePosition(screen_width, screen_height, self.getWidth(), self.getHeight());
        self.x = pos.x;
        self.y = pos.y;

        // Si es un ButtonGroup, también reposicionar sus botones internos
        if (self.inner == .widget_group) {
            self.inner.widget_group.repositionWidgets(self.x, self.y);
        }
    }

    pub fn getWidth(self: *const Self) i32 {
        return self.inner.getWidth();
    }

    pub fn getHeight(self: *const Self) i32 {
        return self.inner.getHeight();
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

    pub fn getWidth(self: *const Self) i32 {
        return switch (self.*) {
            .text => |t| t.getWidth(),
            .underlined_text => |ut| ut.getWidth(),
            .button => |b| b.getWidth(),
            .widget_group => |bg| bg.calculateTotalWidth(),
            else => 0,
        };
    }

    pub fn getHeight(self: *const Self) i32 {
        return switch (self.*) {
            .text => |t| t.getHeight(),
            .underlined_text => |ut| ut.getHeight(),
            .button => |b| b.getHeight(),
            .widget_group => |bg| bg.calculateTotalHeight(),
            else => 0,
        };
    }
};
