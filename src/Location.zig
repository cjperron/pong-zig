const std = @import("std");

/// Location representa una posición 2D con coordenadas x, y usando @Vector para mejor rendimiento
vec: @Vector(2, i32),

const Self = @This();

/// Crea una nueva Location con las coordenadas especificadas
pub fn init(x_val: i32, y_val: i32) Self {
    return Self{ .vec = .{ x_val, y_val } };
}

/// Crea una Location en el origen (0, 0)
pub fn zero() Self {
    return Self{ .vec = .{ 0, 0 } };
}

/// Obtiene la coordenada x
pub inline fn x(self: Self) i32 {
    return self.vec[0];
}

/// Obtiene la coordenada y
pub inline fn y(self: Self) i32 {
    return self.vec[1];
}

/// Suma dos Locations (usa operaciones vectorizadas)
pub fn add(self: Self, other: Self) Self {
    return Self{ .vec = self.vec + other.vec };
}

/// Resta dos Locations (usa operaciones vectorizadas)
pub fn sub(self: Self, other: Self) Self {
    return Self{ .vec = self.vec - other.vec };
}

/// Multiplica la Location por un escalar (usa operaciones vectorizadas)
pub fn scale(self: Self, factor: i32) Self {
    const scalar_vec: @Vector(2, i32) = @splat(factor);
    return Self{ .vec = self.vec * scalar_vec };
}

/// Divide la Location por un escalar
pub fn div(self: Self, divisor: i32) Self {
    const scalar_vec: @Vector(2, i32) = @splat(divisor);
    return Self{ .vec = @divFloor(self.vec, scalar_vec) };
}

/// Verifica si dos Locations son iguales
pub fn eql(self: Self, other: Self) bool {
    return @reduce(.And, self.vec == other.vec);
}

/// Calcula la distancia Manhattan (|x1-x2| + |y1-y2|)
pub fn distanceManhattan(self: Self, other: Self) i32 {
    const diff_vec = self.vec - other.vec;
    const abs_diff: @Vector(2, i32) = @select(i32, diff_vec >= @as(@Vector(2, i32), @splat(0)), diff_vec, -diff_vec);
    return @reduce(.Add, abs_diff);
}

/// Calcula la distancia cuadrada (evita sqrt para mejor rendimiento)
pub fn distanceSquared(self: Self, other: Self) i32 {
    const diff = self.vec - other.vec;
    const squared = diff * diff;
    return @reduce(.Add, squared);
}
