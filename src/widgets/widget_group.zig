const std = @import("std");

const Widget = @import("../widget.zig").Widget;

pub const Orientation = enum {
    Vertical,
    Horizontal,
};

pub const WidgetGroup = struct {
    widgets: std.ArrayList(Widget),
    spacing: i32,
    orientation: Orientation,

    const Self = @This();

    pub fn init(options: struct {
        buttons: std.ArrayList(Widget),
        spacing: i32 = 5,
        orientation: Orientation = .Vertical,
    }) !Self {
        return Self{
            .widgets = options.buttons,
            .spacing = options.spacing,
            .orientation = options.orientation,
        };
    }

    pub fn repositionWidgets(self: *Self, base_x: i32, base_y: i32) void {
        var current_y = base_y;
        var current_x = base_x;

        for (self.widgets.items) |*widget| {
            widget.x = current_x;
            widget.y = current_y;

            // Obtener dimensiones del botón para calcular el siguiente offset
            const height = switch (widget.inner) {
                .button => |b| b.getHeight(),
                else => 0,
            };
            const width = switch (widget.inner) {
                .button => |b| b.getWidth(),
                else => 0,
            };

            switch (self.orientation) {
                .Vertical => current_y += height + self.spacing,
                .Horizontal => current_x += width + self.spacing,
            }
        }
    }

    pub fn update(self: *Self) void {
        for (self.widgets.items) |*widget| {
            widget.update();
        }
    }

    pub fn draw(self: *const Self) void {
        for (self.widgets.items) |*widget| {
            widget.draw();
        }
    }

    pub fn deinit(self: *Self, allocator: std.mem.Allocator) void {
        for (self.widgets.items) |*widget| {
            widget.deinit(allocator);
        }
        self.widgets.deinit(allocator);
    }

    pub fn calculateTotalWidth(self: *const Self) i32 {
        if (self.widgets.items.len == 0) return 0;

        return switch (self.orientation) {
            .Horizontal => {
                var total: i32 = 0;
                for (self.widgets.items, 0..) |*widget, i| {
                    total += widget.getWidth();
                    if (i < self.widgets.items.len - 1) {
                        total += self.spacing;
                    }
                }
                return total;
            },
            .Vertical => {
                var max_width: i32 = 0;
                for (self.widgets.items) |*widget| {
                    max_width = @max(max_width, widget.getWidth());
                }
                return max_width;
            },
        };
    }

    /// Calcula el alto total del grupo según su orientación
    pub fn calculateTotalHeight(self: *const Self) i32 {
        if (self.widgets.items.len == 0) return 0;

        return switch (self.orientation) {
            .Vertical => {
                var total: i32 = 0;
                for (self.widgets.items, 0..) |*widget, i| {
                    total += widget.getHeight();
                    if (i < self.widgets.items.len - 1) {
                        total += self.spacing;
                    }
                }
                return total;
            },
            .Horizontal => {
                var max_height: i32 = 0;
                for (self.widgets.items) |*widget| {
                    max_height = @max(max_height, widget.getHeight());
                }
                return max_height;
            },
        };
    }
};
