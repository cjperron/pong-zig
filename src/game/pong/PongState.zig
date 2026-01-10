const std = @import("std");

const pong_bg_color = @import("../../widget.zig").pong_bg_color;
const U8StringZ = @import("../../string.zig").U8StringZ;
const Location = @import("../../Location.zig");

// Estado global del juego Pong
player1_score: u32,
player2_score: u32,

player1_name: [:0]const u8,
player2_name: [:0]const u8,

ball_location: Location,



const Self = @This();


pub fn getInstanceMut() *Self {
    if (is_initialized) {
        return &instance;
    } else {
        instance = default;
        is_initialized = true;
        return &instance;
    }
}

pub fn getInstance() *const Self {
    return &Self.getInstanceMut().*; // "re-borrow"
}

pub fn resetScores(self: *Self) void {
    self.player1_score = 0;
    self.player2_score = 0;
}

pub fn setPlayerNames(self: *Self, name1: [:0]const u8, name2: [:0]const u8) void {
    self.player1_name = name1;
    self.player2_name = name2;
}

// Logica Singleton.
var instance: Self = undefined;
var is_initialized: bool = false;

// Constantes utiles
const default = Self{
    .player1_score = 0,
    .player2_score = 0,
    .player1_name = "Jugador",
    .player2_name = "Rival",
    .ball_location = Location.init(0, 0),
};
