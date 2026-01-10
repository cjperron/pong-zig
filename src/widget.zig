const std = @import("std");
const rl = @import("raylib");
const Callback = @import("root.zig").Callback;
pub const pong_bg_color = rl.Color{ .r = 20, .g = 20, .b = 30, .a = 255 }; // color a dedo
const U8StringZ = @import("root.zig").U8StringZ;
const Location = @import("Location.zig");

// Importar widgets individuales
const Text = @import("widgets/Text.zig");
const UnderlinedText = @import("widgets/UnderlinedText.zig");
const Button = @import("widgets/Button.zig");
const WidgetGroup = @import("widgets/WidgetGroup.zig");
const TextInput = @import("widgets/TextInput.zig");

// Drawable only
const Box = @import("widgets/Box.zig");
const Line = @import("widgets/Line.zig");
const Circle = @import("widgets/Circle.zig");

// Extra types
const Orientation = @import("widgets/WidgetGroup.zig").Orientation;

// Constantes

// In screen coordinates: Up is -Y, Down is +Y
pub const north = rl.Vector2{ .x = 0.0, .y = -1.0 };
pub const east = rl.Vector2{ .x = 1.0, .y = 0.0 };
pub const south = rl.Vector2{ .x = 0.0, .y = 1.0 };
pub const west = rl.Vector2{ .x = -1.0, .y = 0.0 };

pub const northeast = rl.Vector2{ .x = 1.0, .y = -1.0 };
pub const northwest = rl.Vector2{ .x = -1.0, .y = -1.0 };
pub const southeast = rl.Vector2{ .x = 1.0, .y = 1.0 };
pub const southwest = rl.Vector2{ .x = -1.0, .y = 1.0 };

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
    Absolute: Location,
    Anchored: struct {
        anchor: Anchor,
        offset_x: i32 = 0,
        offset_y: i32 = 0,
    },

    /// Calcula la posición considerando las dimensiones del widget
    pub fn calculatePosition(self: LayoutInfo, screen_width: i32, screen_height: i32, widget_width: i32, widget_height: i32) Location {
        switch (self) {
            .Absolute => |abs| return abs,
            .Anchored => |anchored| {
                const base_pos = switch (anchored.anchor) {
                    .TopLeft => Location.init(0, 0),
                    .Top => Location.init(@divFloor(screen_width, 2) - @divFloor(widget_width, 2), 0),
                    .TopRight => Location.init(screen_width - widget_width, 0),
                    .Left => Location.init(0, @divFloor(screen_height, 2) - @divFloor(widget_height, 2)),
                    .Center => Location.init(@divFloor(screen_width, 2) - @divFloor(widget_width, 2), @divFloor(screen_height, 2) - @divFloor(widget_height, 2)),
                    .Right => Location.init(screen_width - widget_width, @divFloor(screen_height, 2) - @divFloor(widget_height, 2)),
                    .BottomLeft => Location.init(0, screen_height - widget_height),
                    .Bottom => Location.init(@divFloor(screen_width, 2) - @divFloor(widget_width, 2), screen_height - widget_height),
                    .BottomRight => Location.init(screen_width - widget_width, screen_height - widget_height),
                };
                return Location.init(base_pos.x() + anchored.offset_x, base_pos.y() + anchored.offset_y);
            },
        }
    }
};

// ===== Widget =====

pub const Widget = struct {
    location: Location,
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
            .location = undefined,
            .layout_info = options.layout_info,
            .inner = .{ .text = try Text.init(allocator, .{
                .text = options.text,
                .font_size = options.font_size,
                .color = options.color,
                .on_update = options.on_update,
                .default = options.default,
            }) },
        };
        wget.location = options.layout_info.calculatePosition(rl.getScreenWidth(), rl.getScreenHeight(), wget.getWidth(), wget.getHeight());
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
            .location = undefined,
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
        wget.location = options.layout_info.calculatePosition(rl.getScreenWidth(), rl.getScreenHeight(), wget.getWidth(), wget.getHeight());
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
            .location = undefined,
            .layout_info = options.layout_info,
            .inner = .{ .button = try Button.init(allocator, .{
                .label = options.label,
                .font_size = options.font_size,
                .color = options.color,
                .bg_color = options.bg_color,
                .on_click = options.on_click,
            }) },
        };
        wget.location = options.layout_info.calculatePosition(rl.getScreenWidth(), rl.getScreenHeight(), wget.getWidth(), wget.getHeight());
        return wget;
    }

    pub fn initWidgetGroup(
        options: struct {
            widgets: std.ArrayList(Widget),
            spacing: i32 = 5,
            orientation: Orientation = .Vertical,
            layout_info: LayoutInfo = .{ .Absolute = Location.zero() }, // def: (0,0)
        },
    ) Self {
        var wget = Self{
            .location = undefined,
            .layout_info = options.layout_info,
            .inner = .{ .widget_group = .init(.{
                .buttons = options.widgets,
                .spacing = options.spacing,
                .orientation = options.orientation,
            }) },
        };
        wget.location = options.layout_info.calculatePosition(rl.getScreenWidth(), rl.getScreenHeight(), wget.getWidth(), wget.getHeight());
        // Posicionar botones inicialmente
        wget.inner.widget_group.repositionWidgets(wget.location);
        return wget;
    }

    pub fn initTextInput(allocator: std.mem.Allocator, options: struct {
        default_text: []const u8 = "",
        font_size: i32 = 20,
        color: rl.Color = .white,
        char_limit: usize = 50,
        layout_info: LayoutInfo,
    }) !Self {
        var wget = Self{
            .location = undefined,
            .layout_info = options.layout_info,
            .inner = .{ .text_input = try .init(allocator, .{
                .default_text = options.default_text,
                .font_size = options.font_size,
                .color = options.color,
                .char_limit = options.char_limit,
            }) },
        };
        wget.location = options.layout_info.calculatePosition(rl.getScreenWidth(), rl.getScreenHeight(), wget.getWidth(), wget.getHeight());
        return wget;
    }

    pub fn initBox(options: struct {
        layout_info: LayoutInfo = .{ .Absolute = .init(0, 0) },
        color: rl.Color = pong_bg_color,
        width: i32 = 100,
        height: i32 = 100,
        fill: bool = false,
    }) !Self {
        var wget = Self{
            .location = undefined,
            .layout_info = options.layout_info,
            .inner = .{ .box = try Box.init(.{
                .color = options.color,
                .width = options.width,
                .height = options.height,
                .fill = options.fill,
            }) },
        };
        wget.location = options.layout_info.calculatePosition(rl.getScreenWidth(), rl.getScreenHeight(), wget.getWidth(), wget.getHeight());
        return wget;
    }

    pub fn initLine(
        options: struct {
            layout_info: LayoutInfo = .{ .Absolute = .init(0, 0) }, // start point
            color: rl.Color = rl.Color.white,
            thickness: i32 = 2,
            length: f32 = 100.0,
            direction: rl.Vector2 = rl.Vector2{ .x = 1.0, .y = 0.0 },
        },
    ) Self {
        var wget = Self{
            .location = undefined,
            .layout_info = options.layout_info,
            .inner = .{ .line = .init(.{
                .color = options.color,
                .thickness = options.thickness,
                .length = options.length,
                .direction = options.direction,
            }) },
        };
        std.debug.assert(wget.getWidth() == 0 and wget.getHeight() == 0);
        wget.location = options.layout_info.calculatePosition(rl.getScreenWidth(), rl.getScreenHeight(), wget.getWidth(), wget.getHeight());
        return wget;
    }

    pub fn initCircle(
        options: struct {
            layout_info: LayoutInfo = .{ .Absolute = .init(0, 0) }, // center point
            color: rl.Color = rl.Color.white,
            radius: i32 = 50,
            fill: bool = false,
        },
    ) Self {
        var wget = Self{
            .location = undefined,
            .layout_info = options.layout_info,
            .inner = .{ .circle = .init(.{
                .color = options.color,
                .radius = options.radius,
                .fill = options.fill,
            }) },
        };
        wget.location = options.layout_info.calculatePosition(rl.getScreenWidth(), rl.getScreenHeight(), wget.getWidth(), wget.getHeight());
        return wget;
    }

    pub fn reposition(self: *Self) void {
        const screen_width = rl.getScreenWidth();
        const screen_height = rl.getScreenHeight();
        self.location = self.layout_info.calculatePosition(screen_width, screen_height, self.getWidth(), self.getHeight());

        // Si es un ButtonGroup, también reposicionar sus botones internos
        if (self.inner == .widget_group) {
            self.inner.widget_group.repositionWidgets(self.location);
        }
    }

    pub fn getWidth(self: *const Self) i32 {
        return self.inner.getWidth();
    }

    pub fn getHeight(self: *const Self) i32 {
        return self.inner.getHeight();
    }

    pub fn draw(self: *const Self) void {
        self.inner.draw(self.location);
    }

    pub fn update(self: *Self) void {
        self.inner.update(self.location);
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
    text_input: TextInput,
    box: Box,
    line: Line,
    circle: Circle,
    _,

    const Self = @This();

    pub fn draw(self: *const Self, location: Location) void {
        switch (self.*) {
            inline else => |*impl| {
                const ImplType = @TypeOf(impl.*);
                if (ImplType != void and @hasDecl(ImplType, "draw")) {
                    const drawFn = @field(ImplType, "draw");
                    const params = @typeInfo(@TypeOf(drawFn)).@"fn".params;
                    if (params.len == 2) {
                        impl.draw(location);
                    } else if (params.len == 1) {
                        impl.draw();
                    }
                }
            },
        }
    }

    pub fn update(self: *Self, location: Location) void {
        switch (self.*) {
            inline else => |*impl| {
                const ImplType = @TypeOf(impl.*);
                if (ImplType != void and @hasDecl(ImplType, "update")) {
                    const updateFn = @field(ImplType, "update");
                    const params = @typeInfo(@TypeOf(updateFn)).@"fn".params;
                    if (params.len == 2) {
                        impl.update(location);
                    } else if (params.len == 1) {
                        impl.update();
                    }
                }
            },
        }
    }

    pub fn deinit(self: *Self, allocator: std.mem.Allocator) void {
        switch (self.*) {
            inline else => |*impl| {
                const ImplType = @TypeOf(impl.*);
                if (ImplType != void and @hasDecl(ImplType, "deinit")) {
                    const deinitFn = @field(ImplType, "deinit");
                    const params = @typeInfo(@TypeOf(deinitFn)).@"fn".params;
                    if (params.len == 2) {
                        impl.deinit(allocator);
                    } else if (params.len == 1) {
                        impl.deinit();
                    }
                }
            },
        }
    }

    pub fn getWidth(self: *const Self) i32 {
        switch (self.*) {
            inline else => |*impl| {
                const ImplType = @TypeOf(impl.*);
                if (ImplType != void) {
                    if (@hasDecl(ImplType, "getWidth")) {
                        return impl.getWidth();
                    } else if (@hasDecl(ImplType, "calculateTotalWidth")) {
                        return impl.calculateTotalWidth();
                    }
                }
                return 0;
            },
        }
    }

    pub fn getHeight(self: *const Self) i32 {
        switch (self.*) {
            inline else => |*impl| {
                const ImplType = @TypeOf(impl.*);
                if (ImplType != void) {
                    if (@hasDecl(ImplType, "getHeight")) {
                        return impl.getHeight();
                    } else if (@hasDecl(ImplType, "calculateTotalHeight")) {
                        return impl.calculateTotalHeight();
                    }
                }
                return 0;
            },
        }
    }
};
