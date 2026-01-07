const std = @import("std");

// ===== Generic Serializer and Deserializer =====

pub fn serialize(comptime T: type, w: *std.Io.Writer, value: T) !void {
    const ti = @typeInfo(T);

    switch (ti) {
        .bool => {
            const b: u8 = if (value) 1 else 0;
            try w.writeAll(&[_]u8{b});
        },

        .float => {
            try writeFloat(w, T, value);
        },

        .int => {
            try writeInt(w, T, value);
        },

        .@"enum" => {
            const Tag = ti.Enum.tag_type;
            try writeInt(w, Tag, @intFromEnum(value));
        },

        .optional => |opt| {
            if (value) |some| {
                try w.writeAll(&[_]u8{1});
                try serialize(opt.child, w, some);
            } else {
                try w.writeAll(&[_]u8{0});
            }
        },

        .array => |arr| {
            // Serializa elementos en orden.
            for (value) |elem| {
                try serialize(arr.child, w, elem);
            }
        },

        .pointer => |ptr| {
            // Soportamos slices: []T y []const T.
            if (ptr.size != .slice) return error.UnsupportedType;

            const Child = ptr.child;
            const len: u64 = @intCast(value.len);
            try writeInt(w, u64, len);

            // Fast path para bytes
            if (Child == u8) {
                try w.writeAll(value);
            } else {
                for (value) |elem| {
                    try serialize(Child, w, elem);
                }
            }
        },

        .@"struct" => |st| {
            // OJO: esto fija el layout lógico al ORDEN DE CAMPOS del struct.
            inline for (st.fields) |f| {
                const field_val = @field(value, f.name);
                try serialize(f.type, w, field_val);
            }
        },

        else => return error.UnsupportedType,
    }
}

pub fn deserialize(
    comptime T: type,
    r: *std.Io.Reader,
    allocator: ?std.mem.Allocator,
) !T {
    const ti = @typeInfo(T);
    switch (ti) {

        .bool => {
            const b = try readByte(r);
            return switch (b) {
                0 => false,
                1 => true,
                else => error.InvalidBool,
            };
        },

        .int => return try readInt(r, T),

        .float => return try readFloat(r, T),

        .@"enum" => {
            const Tag = ti.Enum.tag_type;
            const raw = try readInt(r, Tag);
            return @enumFromInt(raw);
        },

        .optional => |opt| {
            const tag = try readByte(r);
            if (tag == 0) return null;
            if (tag == 1) {
                const v = try deserialize(opt.child, r, allocator);
                return v;
            }
            return error.UnsupportedType;
        },

        .array => |arr| {
            var out: T = undefined;
            var i: usize = 0;
            while (i < arr.len) : (i += 1) {
                out[i] = try deserialize(arr.child, r, allocator);
            }
            return out;
        },

        .pointer => |ptr| {
            if (ptr.size != .slice) return error.UnsupportedType;
            if (allocator == null) return error.OutOfMemory; // o definí tu propio error "NeedAllocator"

            const Child = ptr.child;
            const len_u64 = try readInt(r, u64);
            const len: usize = @intCast(len_u64);

            const a = allocator.?;
            if (Child == u8) {
                const buf = try a.alloc(u8, len);
                errdefer a.free(buf);
                try readExact(r, buf);
                return buf;
            } else {
                const buf = try a.alloc(Child, len);
                errdefer a.free(buf);
                for (buf) |*slot| {
                    slot.* = try deserialize(Child, r, allocator);
                }
                return buf;
            }
        },

        .@"struct" => |st| {
            var out: T = undefined;
            inline for (st.fields) |f| {
                @field(out, f.name) = try deserialize(f.type, r, allocator);
            }
            return out;
        },

        else => return error.UnsupportedType,
    }
}

// Read helpers

fn readByte(r: *std.Io.Reader) std.Io.Reader.Error!u8 {
    var b: [1]u8 = undefined;
    try readExact(r, &b);
    return b[0];
}

fn readInt(r: *std.Io.Reader, comptime IntT: type) std.Io.Reader.Error!IntT {
    var buf: [@sizeOf(IntT)]u8 = undefined;
    try readExact(r, &buf);
    return std.mem.readInt(IntT, &buf, .little);
}

fn readFloat(r: *std.Io.Reader, comptime FloatT: type) std.Io.Reader.Error!FloatT {
    const Bits = std.meta.Int(.unsigned, @bitSizeOf(FloatT));
    const as_int = try readInt(r, Bits);
    return @bitCast(as_int);
}

/// Lee exactamente buf.len bytes o falla.
fn readExact(r: *std.Io.Reader, buf: []u8) std.Io.Reader.Error!void {
    // En la nueva std.Io, el reader es un ring buffer y tiene operaciones “take/peek”.
    // La forma más estable/portable es iterar y completar el buffer.
    var filled: usize = 0;
    while (filled < buf.len) {
        // `take(n)` aparece en la API nueva (release notes muestran `takeDelimiterExclusive`). :contentReference[oaicite:1]{index=1}
        // Si tu build específica usa otro nombre, reemplazalo por el equivalente (take/recv/readVec wrapper).
        const chunk = try r.take(buf.len - filled);
        std.mem.copyForwards(u8, buf[filled..][0..chunk.len], chunk);
        filled += chunk.len;
    }
}

// Write helpers

fn writeInt(w: *std.Io.Writer, comptime IntT: type, x: IntT) std.Io.Writer.Error!void {
    var buf: [@sizeOf(IntT)]u8 = undefined;
    std.mem.writeInt(IntT, &buf, x, .little);
    try w.writeAll(&buf);
}

fn writeFloat(w: *std.Io.Writer, comptime FloatT: type, x: FloatT) std.Io.Writer.Error!void {
    const Bits = std.meta.Int(.unsigned, @bitSizeOf(FloatT));
    const as_int: Bits = @bitCast(x);
    try writeInt(w, Bits, as_int);
}
