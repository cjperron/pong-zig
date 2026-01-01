const std = @import("std");
const rl = @import("raylib");
const pong_zig = @import("pong_zig");

const Widget = pong_zig.widgets.Widget;
const Text = pong_zig.widgets.Text;
const Callback = pong_zig.Callback;

const background_color = rl.Color{ .r = 20, .g = 20, .b = 30, .a = 255 }; // color a dedo

pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const displayConfig = try pong_zig.DisplayConfig.load();

    const screenWidth = displayConfig.res.width;
    const screenHeight = displayConfig.res.height;
    var should_exit: bool = false;

    rl.setConfigFlags(.{ .window_hidden = true });

    rl.initWindow(screenWidth, screenHeight, "Pong-Zig");

    defer rl.closeWindow(); // Close window and OpenGL context

    const display_refresh_rate = rl.getMonitorRefreshRate(rl.getCurrentMonitor());

    rl.setTargetFPS(display_refresh_rate); // Set our game to run at 120 frames-per-second
    //--------------------------------------------------------------------------------------

    // init allocator
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    // init widgets
    var main_menu_widgets: std.ArrayList(Widget) = try std.ArrayList(Widget).initCapacity(alloc, 16);
    defer main_menu_widgets.deinit(alloc);

    // widgets
    const titulo: Widget = Widget.initUnderlinedText(.{
        .text = "PONG",
        .x = @divTrunc(screenWidth - rl.measureText("PONG", 120), 2), // center text
        .y = 150,
        .font_size = 120,
    });

    try main_menu_widgets.append(alloc, titulo);

    // Botones
    const jugar_btn: Widget = Widget.initButton(.{
        .label = "Jugar",
        .font_size = 40,
        .bg_color = background_color,
    });

    const options_btn: Widget = Widget.initButton(.{
        .label = "Opciones",
        .font_size = 40,
        .bg_color = background_color,
    });

    // Explicacion : Para crear una funcion anonima SIN heap allocs, se necesita un contexto, y una funcion miembro.
    // Por ende, la solucion mas facil es tener un struct anonimo con una funcion call que se comporte exactamente como queremos.
    var ctx_salir_btn = struct {
        should_exit: *bool,
        // Lista de capturas....
        //
        // ...
        pub fn call(self: *@This()) void { // la closure en si
            // Set the flag to exit the main loop
            self.should_exit.* = true;
        }
    }{
        .should_exit = &should_exit, // Inicializo a mano las capturas.
    };

    const salir_btn: Widget = Widget.initButton(.{
        .label = "Salir",
        .font_size = 40,
        .bg_color = background_color,
        .on_click = Callback.init(&ctx_salir_btn),
    });

    var menu_buttons = [_]pong_zig.widgets.Button{
        jugar_btn.button,
        options_btn.button,
        salir_btn.button,
    };

    // Menu de selección
    const menu_selection_widget: Widget = Widget.initMenuSelection(.{
        .buttons = menu_buttons[0..],
        .selected_index = 0,
        .x = @divTrunc(screenWidth - 200, 2),
        .y = 400,
        .spacing = 20,
    });

    try main_menu_widgets.append(alloc, menu_selection_widget);

    // Initial draw
    draw_main_menu(main_menu_widgets.items);
    rl.clearWindowState(.{ .window_hidden = true });

    // Main game loop
    while (!rl.windowShouldClose() ^ should_exit) { // Cierro la ventana, o por raylib, o por mi.
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
