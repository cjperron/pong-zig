const std = @import("std");
const pong_zig = @import("pong_zig");
const rl = @import("raylib");

var displayConfig: pong_zig.DisplayConfig = undefined;

pub fn main() anyerror!void {
    // Prints to stderr, ignoring potential errors.
    // std.debug.print("Pong en LAN!\n", .{});
    // Initialization
    //--------------------------------------------------------------------------------------

    displayConfig = try pong_zig.DisplayConfig.load();

    const screenWidth = displayConfig.res.width;
    const screenHeight = displayConfig.res.height;

    rl.initWindow(screenWidth, screenHeight, "Pong - Menu Principal");

    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        // TODO: Update your variables here
        //----------------------------------------------------------------------------------
        draw_main_menu();
    }
}

fn draw_main_menu() void {
    const background_color = rl.Color{ .r = 20, .g = 20, .b = 30, .a = 255 };
    const screenWidth = displayConfig.res.width;
    // const screenHeight = displayConfig.res.height;
    // Draw
    //----------------------------------------------------------------------------------
    rl.beginDrawing();
    defer rl.endDrawing();

    // Fondo oscuro
    rl.clearBackground(background_color);

    // Título "PONG" en grande
    const title = "PONG";
    const fontSize = 120;
    const titleWidth = rl.measureText(title, fontSize);
    const titleX = @divTrunc(screenWidth - titleWidth, 2);
    const titleY = 150;

    rl.drawText(title, titleX, titleY, fontSize, .white);

    // Línea de subrayado
    const offset = -10;
    const lineY = titleY + fontSize + offset;
    const lineWidth = titleWidth;
    rl.drawRectangle(titleX, lineY, lineWidth, 5, .white);
    //----------------------------------------------------------------------------------

}
