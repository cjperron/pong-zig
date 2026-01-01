const std = @import("std");
const rl = @import("raylib");
const pong_zig = @import("pong_zig");

const Widget = pong_zig.widgets.Widget;
const Text = pong_zig.widgets.Text;

var displayConfig: pong_zig.DisplayConfig = undefined;

var screenWidth: i32 = undefined;
var screenHeight: i32 = undefined;

pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------
    displayConfig = try pong_zig.DisplayConfig.load();

    screenWidth = displayConfig.res.width;
    screenHeight = displayConfig.res.height;

    rl.initWindow(screenWidth, screenHeight, "Pong - Menu Principal");

    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // init allocator
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    // init widgets
    var main_menu_widgets: std.ArrayList(Widget) = try std.ArrayList(Widget).initCapacity(alloc, 16);
    defer main_menu_widgets.deinit(alloc);


    // widgets
    const title_text = "PONG";
    const title_font_size = 120;
    const title_width = rl.measureText(title_text, title_font_size);
    const title_x = @divTrunc(screenWidth - title_width, 2);
    const title_y = 150;

    const titulo: Widget = Widget.initUnderlinedText(.{ .inner_text = Text.init(.{
        .text = title_text,
        .x = title_x,
        .y = title_y,
        .font_size = title_font_size,
        .color = rl.Color.white,
        .update_condition = &struct {
            pub fn update_c() bool {
                return true;
            }
        }.update_c,
        .update_action = &struct {
            pub fn update_a(this: *Text) void {
                this.*.y = @mod((this.*.y + 1), screenHeight - 120);
            }
        }.update_a,
    })
    // underline defaulted
    });

    try main_menu_widgets.append(alloc, titulo);

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        update_main_menu(main_menu_widgets.items);
        // Draw
        draw_main_menu(main_menu_widgets.items);
    }
}

fn update_main_menu(w: []Widget) void {
    for (w) |*widget| {
        widget.update();
    }
}

fn draw_main_menu(w: []Widget) void {
    const background_color = rl.Color{ .r = 20, .g = 20, .b = 30, .a = 255 };
    // const screenWidth = displayConfig.res.width;
    // const screenHeight = displayConfig.res.height;
    // Draw
    //----------------------------------------------------------------------------------
    rl.beginDrawing();
    defer rl.endDrawing();

    // Fondo oscuro
    rl.clearBackground(background_color);

    for (w) |widget| {
        widget.draw();
    }
}
