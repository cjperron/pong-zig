const std = @import("std");
const rl = @import("raylib");
const Location = @import("../Location.zig");
const widget = @import("../widget.zig");
const pong_fg_color = widget.pong_bg_color;

// Campos
color: rl.Color,
thickness: i32, // grosor de la linea
direction: rl.Vector2, // tiene que estar normalizado
length: f32,

const Self = @This();

pub fn init(options: struct {
    color: rl.Color = .white,
    thickness: i32 = 2,
    direction: rl.Vector2 = widget.east,
    length: f32 = 100.0,
}) Self {
    return Self{
        .direction = options.direction.normalize(),
        .length = options.length,
        .color = options.color,
        .thickness = options.thickness,
    };
}

pub fn draw(self: *const Self, start: Location) void {
    const start_v = rl.Vector2{
        .x = @floatFromInt(start.x()),
        .y = @floatFromInt(start.y()),
    };
    const end_v = rl.Vector2{
        .x = start_v.x + self.direction.x * self.length,
        .y = start_v.y + self.direction.y * self.length,
    };
    rl.drawLineEx(start_v, end_v, @floatFromInt(self.thickness), self.color);
}

// NOTA
// No tiene getWidth/getHeight porque una linea no tiene un ancho o alto en el sentido normal,
// dado que puede ser una linea entre 2 puntos cualquiera, la nocion correcta es pensar a la linea
// como 2 puntos conectados + un grosor.
//
// al mismo tiempo, update() no tiene sentido porque una linea no tiene estado **Interno** que actualizar.
