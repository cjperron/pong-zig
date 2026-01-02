const std = @import("std");

const pz = @import("pong_zig");
const Widget = pz.display.widgets.Widget;
const Text = pz.display.widgets.Text;
const Callback = pz.Callback;
const rl = @import("raylib");

pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const displayConfig = pz.display.config.DisplayConfig.getInstance();

    const screenWidth = displayConfig.res.width;
    const screenHeight = displayConfig.res.height;

    rl.initWindow(screenWidth, screenHeight, "Pong-Zig");
    defer rl.closeWindow(); // Close window and OpenGL context

    const display_refresh_rate = rl.getMonitorRefreshRate(rl.getCurrentMonitor());

    rl.setTargetFPS(display_refresh_rate); // Set our game to run at our monitor refresh rate
    //--------------------------------------------------------------------------------------

    // init allocator
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();


    // Main game loop
    var current_scene = try pz.display.scene.Scene.init(alloc, .MainMenu, .{});
    defer current_scene.deinit(alloc);

    const app_state = pz.app.AppState.getInstanceMut();

    while (!rl.windowShouldClose() ^ app_state.should_exit) { // Cierro la ventana, o por raylib, o por mi.
        // Update
        if (current_scene.update()) |new_scene_tag| {
            current_scene.deinit(alloc);
            current_scene = try pz.display.scene.Scene.init(alloc, new_scene_tag, .{});
        }
        // Draw
        rl.beginDrawing();
        rl.clearBackground(pz.display.config.pong_bg_color);
        current_scene.draw();
        rl.endDrawing();
    }
}
