const std = @import("std");

const PongState = @import("./PongState.zig");

pub fn step() void {
    const p_state = PongState.getInstanceMut();
    // Lógica del juego aquí
    _ = p_state;
}
