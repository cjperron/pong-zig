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
};
