const std = @import("std");

const pz = @import("pong_zig");
const Widget = pz.display.widgets.Widget;
const Text = pz.display.widgets.Text;
const Callback = pz.Callback;
const rl = @import("raylib");

pub fn main() anyerror!void {

    // ============================
	// ====== Initialization ======
    // ============================

    // init allocator
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();
    const app_state = pz.app.AppState.getInstanceMut();

    const screen_res = app_state.config.display_config.getResolution();

    rl.initWindow(screen_res.width, screen_res.height, "Pong-Zig");
    defer rl.closeWindow(); // Close window and OpenGL context

    const display_refresh_rate = rl.getMonitorRefreshRate(rl.getCurrentMonitor());

    rl.setTargetFPS(display_refresh_rate); // Set our game to run at our monitor refresh rate

    if (app_state.config.display_config.fullscreen) {
		rl.toggleFullscreen();
	}
    // ===========================
    // ===== Main game loop ======
	// ===========================

	var current_scene = try pz.display.scene.Scene.init(alloc, .MainMenu, .{});
    defer current_scene.deinit(alloc);

    while (!app_state.should_exit) { // Cierro la ventana, o por raylib, o por mi.
        // Update
        current_scene.update();
        if (app_state.requested_scene) |new_scene_tag| {
            current_scene.deinit(alloc);
            current_scene = try pz.display.scene.Scene.init(alloc, new_scene_tag, .{});
            app_state.current_scene = new_scene_tag;
            app_state.requested_scene = null;
        }
        // Draw
        rl.beginDrawing();
        rl.clearBackground(pz.display.widgets.pong_bg_color);
        current_scene.draw();
        rl.endDrawing();
    }
}
