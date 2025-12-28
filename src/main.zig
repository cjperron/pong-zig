const std = @import("std");
const pong_zig = @import("pong_zig");
const rl = @import("raylib");


pub fn main() !void {
    // Prints to stderr, ignoring potential errors.
    std.debug.print("Pong en LAN!\n", .{});
}
