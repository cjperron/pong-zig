const std = @import("std");

// ===== Generador de números aleatorios =====

prng: std.Random.DefaultPrng,
rand: std.Random,

const Self = @This();

pub fn getInstanceMut() *Self {
    if (!initialized) {
        var seed: u64 = undefined;
        std.posix.getrandom(std.mem.asBytes(&seed)) catch |err| {
            std.debug.print("Failed to get random seed: {}\n", .{err});
            seed = 0; // Fallback seed
        };
        var rng = Self{
            .prng = std.Random.DefaultPrng.init(seed),
            .rand = undefined,
        };
        rng.rand = rng.prng.random();
        global_rng = rng;
        initialized = true;
    }
    return &global_rng;
}

pub fn getInstance() *const Self {
    return &Self.getInstanceMut().*; // "re-borrow"
}

var initialized: bool = false;
var global_rng: Self = undefined;
