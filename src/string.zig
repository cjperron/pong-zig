const std = @import("std");

// ===== Cadenas de texto (Strings) =====

/// U8String es una estructura que envuelve un ArrayList de u8 para proporcionar
/// una interfaz más conveniente para trabajar con cadenas de texto mutables.
///
/// Esta estructura está diseñada para casos donde se necesita construir y manipular
/// cadenas de texto dinámicamente, sin la necesidad de terminación nula.
///
/// Ejemplo de uso:
/// ```
/// var str = try U8String.init(allocator);
/// defer str.deinit();
/// try str.appendSlice(allocator, "Hola");
/// ```
pub const U8String = struct {
    const Self = @This();
    /// ArrayList interno que almacena los bytes de la cadena
    inner: std.ArrayList(u8),

    /// Inicializa una nueva U8String vacía.
    ///
    /// Parámetros:
    ///   - allocator: El asignador de memoria a utilizar
    ///
    /// Retorna:
    ///   - U8String inicializada
    ///   - Error si falla la asignación de memoria
    pub fn init(allocator: std.mem.Allocator) !Self {
        return Self{
            .inner = try std.ArrayList(u8).init(allocator),
        };
    }

    /// Inicializa una nueva U8String con una capacidad específica preasignada.
    /// Esto es útil cuando se conoce de antemano el tamaño aproximado de la cadena
    /// para evitar realocaciones múltiples.
    ///
    /// Parámetros:
    ///   - allocator: El asignador de memoria a utilizar
    ///   - cap: La capacidad inicial en bytes
    ///
    /// Retorna:
    ///   - U8String inicializada con la capacidad especificada
    ///   - Error si falla la asignación de memoria
    pub fn initWithCapacity(allocator: std.mem.Allocator, cap: usize) !Self {
        return Self{
            .inner = try std.ArrayList(u8).initCapacity(allocator, cap),
        };
    }

    /// Retorna la longitud actual de la cadena en bytes.
    ///
    /// Parámetros:
    ///   - self: Puntero constante a la instancia
    ///
    /// Retorna:
    ///   - Número de bytes en la cadena
    pub fn len(self: *const Self) usize {
        return self.inner.items.len;
    }

    /// Retorna la capacidad total asignada para la cadena en bytes.
    /// La capacidad es siempre mayor o igual a la longitud.
    ///
    /// Parámetros:
    ///   - self: Puntero constante a la instancia
    ///
    /// Retorna:
    ///   - Capacidad total en bytes
    pub fn capacity(self: *const Self) usize {
        return self.inner.capacity;
    }

    /// Libera la memoria asociada con esta cadena.
    /// Debe ser llamado cuando la cadena ya no es necesaria.
    ///
    /// Parámetros:
    ///   - self: Puntero mutable a la instancia
    pub fn deinit(self: *Self) void {
        self.inner.deinit();
    }

    /// Agrega un slice de bytes al final de la cadena.
    /// La cadena puede crecer automáticamente si es necesario.
    ///
    /// Parámetros:
    ///   - self: Puntero mutable a la instancia
    ///   - allocator: El asignador de memoria a utilizar para posibles realocaciones
    ///   - slice: El slice de bytes a agregar
    ///
    /// Retorna:
    ///   - void en caso de éxito
    ///   - Error si falla la realocación de memoria
    pub fn appendSlice(self: *Self, allocator: std.mem.Allocator, slice: []const u8) !void {
        try self.inner.appendSlice(allocator, slice);
    }

    /// Retorna un slice de solo lectura que representa la cadena completa.
    /// El slice es válido hasta que la cadena sea modificada o liberada.
    ///
    /// Parámetros:
    ///   - self: Puntero constante a la instancia
    ///
    /// Retorna:
    ///   - Slice de bytes representando la cadena
    pub fn toSlice(self: *const Self) []const u8 {
        return self.inner.items[0..self.len()];
    }

    /// Retorna un slice mutable que representa la cadena completa.
    /// El slice es válido hasta que la cadena sea modificada o liberada.
    /// Permite modificar directamente los bytes de la cadena.
    ///
    /// Parámetros:
    ///   - self: Puntero mutable a la instancia
    ///
    /// Retorna:
    ///   - Slice mutable de bytes representando la cadena
    pub fn toSliceMut(self: *Self) []u8 {
        return self.inner.items[0..self.len()];
    }

    /// Accede al byte en la posición especificada sin verificación de límites.
    /// ADVERTENCIA: Acceder a un índice fuera de límites causa comportamiento indefinido.
    ///
    /// Parámetros:
    ///   - self: Puntero constante a la instancia
    ///   - i: Índice del byte a acceder (base 0)
    ///
    /// Retorna:
    ///   - El byte en la posición especificada
    pub fn at(self: *const Self, i: usize) u8 {
        return self.inner.items[i];
    }

    /// Accede al byte en la posición especificada con verificación de límites.
    /// Entra en pánico si el índice está fuera de límites.
    ///
    /// Parámetros:
    ///   - self: Puntero constante a la instancia
    ///   - i: Índice del byte a acceder (base 0)
    ///
    /// Retorna:
    ///   - El byte en la posición especificada
    ///
    /// Pánico:
    ///   - Si i >= longitud de la cadena
    pub fn atChecked(self: *const Self, i: usize) u8 {
        if (i >= self.inner.items.len) {
            @panic("String index out of bounds");
        }
        return self.inner.items[i];
    }

    /// Obtiene una referencia mutable al byte en la posición especificada sin verificación de límites.
    /// ADVERTENCIA: Acceder a un índice fuera de límites causa comportamiento indefinido.
    ///
    /// Parámetros:
    ///   - self: Puntero mutable a la instancia
    ///   - i: Índice del byte a acceder (base 0)
    ///
    /// Retorna:
    ///   - Referencia mutable al byte en la posición especificada
    pub fn atMut(self: *Self, i: usize) *u8 {
        return &self.inner.items[i];
    }

    /// Obtiene una referencia mutable al byte en la posición especificada con verificación de límites.
    /// Entra en pánico si el índice está fuera de límites.
    ///
    /// Parámetros:
    ///   - self: Puntero mutable a la instancia
    ///   - i: Índice del byte a acceder (base 0)
    ///
    /// Retorna:
    ///   - Referencia mutable al byte en la posición especificada
    ///
    /// Pánico:
    ///   - Si i >= longitud de la cadena
    pub fn atMutChecked(self: *Self, i: usize) *u8 {
        if (i >= self.inner.items.len) {
            @panic("String index out of bounds");
        }
        return &self.inner.items[i];
    }

    /// Limpia el contenido de la cadena, dejándola vacía.
    /// La capacidad asignada se mantiene sin cambios.
    ///
    /// Parámetros:
    ///   - self: Puntero mutable a la instancia
    pub fn clear(self: *Self) void {
        self.inner.clearRetainingCapacity();
    }

    /// Compara esta cadena con otra cadena para verificar si son iguales.
    ///
    /// Parámetros:
    ///   - self: Puntero constante a la instancia
    ///   - other: Puntero constante a la otra cadena a comparar
    ///
    /// Retorna:
    ///   - true si las cadenas son idénticas, false en caso contrario
    pub fn eq(self: *const Self, other: *const Self) bool {
        if (self.len() != other.len()) {
            return false;
        }
        return std.mem.eql(u8, self.toSlice(), other.toSlice());
    }
};

/// U8StringZ es una estructura que envuelve U8String y garantiza que la cadena
/// siempre termina en null (caracter '\0'). Esto es útil para interoperar con
/// APIs de C que esperan cadenas terminadas en null.
///
/// El terminador null no se cuenta en la longitud reportada por len(), pero
/// siempre está presente al final de los datos internos.
///
/// Ejemplo de uso:
/// ```
/// var str = try U8StringZ.init(allocator);
/// defer str.deinit();
/// try str.appendSlice(allocator, "Hola desde C");
/// const c_string = str.toSlice(); // Puede pasarse a funciones de C
/// ```
pub const U8StringZ = struct {
    const Self = @This();
    /// U8String interna que almacena los datos más el terminador null
    inner: U8String,

    /// Inicializa una nueva U8StringZ vacía con terminador null.
    ///
    /// Parámetros:
    ///   - allocator: El asignador de memoria a utilizar
    ///
    /// Retorna:
    ///   - U8StringZ inicializada (conteniendo solo el terminador null)
    ///   - Error si falla la asignación de memoria
    pub fn init(allocator: std.mem.Allocator) !Self {
        var s = try U8String.init(allocator);
        try s.appendSlice(0);
        return Self{
            .inner = s,
        };
    }

    /// Inicializa una nueva U8StringZ con una capacidad específica preasignada.
    /// La cadena contendrá inicialmente solo el terminador null.
    ///
    /// Parámetros:
    ///   - allocator: El asignador de memoria a utilizar
    ///   - cap: La capacidad inicial en bytes (incluyendo el terminador null)
    ///
    /// Retorna:
    ///   - U8StringZ inicializada con la capacidad especificada
    ///   - Error si falla la asignación de memoria
    pub fn initWithCapacity(allocator: std.mem.Allocator, cap: usize) !Self {
        var s = try U8String.initWithCapacity(allocator, cap);
        try s.appendSlice(0);
        return Self{
            .inner = s,
        };
    }

    /// Retorna la longitud de la cadena en bytes, excluyendo el terminador null.
    ///
    /// Parámetros:
    ///   - self: Puntero constante a la instancia
    ///
    /// Retorna:
    ///   - Número de bytes en la cadena (sin contar el '\0')
    pub fn len(self: *const Self) usize {
        if (self.inner.len() == 0) {
            return 0;
        }
        return self.inner.len() - 1; // Excluir el terminador null
    }

    /// Retorna la capacidad total asignada para la cadena en bytes.
    ///
    /// Parámetros:
    ///   - self: Puntero constante a la instancia
    ///
    /// Retorna:
    ///   - Capacidad total en bytes
    pub fn capacity(self: *const Self) usize {
        return self.inner.capacity();
    }

    /// Libera la memoria asociada con esta cadena.
    /// Debe ser llamado cuando la cadena ya no es necesaria.
    ///
    /// Parámetros:
    ///   - self: Puntero mutable a la instancia
    pub fn deinit(self: *Self) void {
        self.inner.deinit();
    }

    /// Retorna un slice terminado en null que representa la cadena completa.
    /// El tipo de retorno [:0]const u8 garantiza la presencia del terminador null
    /// a nivel de tipos, lo que permite pasar directamente a funciones de C.
    ///
    /// Parámetros:
    ///   - self: Puntero constante a la instancia
    ///
    /// Retorna:
    ///   - Slice terminado en null representando la cadena
    pub fn toSlice(self: *const Self) [:0]const u8 {
        return @ptrCast(self.inner.toSlice());
    }

    /// Retorna un slice mutable terminado en null que representa la cadena completa.
    /// El tipo de retorno [:0]u8 garantiza la presencia del terminador null
    /// a nivel de tipos. Permite modificar directamente los bytes de la cadena.
    /// ADVERTENCIA: No modifiques el terminador null final.
    ///
    /// Parámetros:
    ///   - self: Puntero mutable a la instancia
    ///
    /// Retorna:
    ///   - Slice mutable terminado en null representando la cadena
    pub fn toSliceMut(self: *Self) [:0]u8 {
        return @ptrCast(self.inner.toSliceMut());
    }

    /// Agrega un slice de bytes al final de la cadena, manteniendo el terminador null.
    /// El terminador null siempre se mantiene al final después de la operación.
    ///
    /// Parámetros:
    ///   - self: Puntero mutable a la instancia
    ///   - allocator: El asignador de memoria a utilizar para posibles realocaciones
    ///   - slice: El slice de bytes a agregar
    ///
    /// Retorna:
    ///   - void en caso de éxito
    ///   - Error si falla la realocación de memoria
    pub fn appendSlice(self: *Self, allocator: std.mem.Allocator, slice: []const u8) !void {
        // Remover el terminador null temporal
        if (self.inner.len() > 0) {
            _ = self.inner.inner.pop();
        }
        try self.inner.appendSlice(allocator, slice);
        // Re-agregar el terminador null al final
        try self.inner.appendSlice(allocator, 0);
    }

    /// Accede al byte en la posición especificada sin verificación de límites.
    /// ADVERTENCIA: Acceder a un índice fuera de límites causa comportamiento indefinido.
    ///
    /// Parámetros:
    ///   - self: Puntero constante a la instancia
    ///   - i: Índice del byte a acceder (base 0, no incluye el terminador null)
    ///
    /// Retorna:
    ///   - El byte en la posición especificada
    pub fn at(self: *const Self, i: usize) u8 {
        return self.inner.at(i);
    }

    /// Accede al byte en la posición especificada con verificación de límites.
    /// Entra en pánico si el índice está fuera de límites.
    ///
    /// Parámetros:
    ///   - self: Puntero constante a la instancia
    ///   - i: Índice del byte a acceder (base 0, no incluye el terminador null)
    ///
    /// Retorna:
    ///   - El byte en la posición especificada
    ///
    /// Pánico:
    ///   - Si i >= longitud de la cadena (excluyendo el terminador null)
    pub fn atChecked(self: *const Self, i: usize) u8 {
        if (i >= self.len()) {
            @panic("String index out of bounds");
        }
        return self.inner.at(i);
    }

    /// Obtiene una referencia mutable al byte en la posición especificada sin verificación de límites.
    /// ADVERTENCIA: Acceder a un índice fuera de límites causa comportamiento indefinido.
    /// ADVERTENCIA: No accedas al terminador null usando esta función.
    ///
    /// Parámetros:
    ///   - self: Puntero mutable a la instancia
    ///   - i: Índice del byte a acceder (base 0, no incluye el terminador null)
    ///
    /// Retorna:
    ///   - Referencia mutable al byte en la posición especificada
    pub fn atMut(self: *Self, i: usize) *u8 {
        return self.inner.atMut(i);
    }

    /// Obtiene una referencia mutable al byte en la posición especificada con verificación de límites.
    /// Entra en pánico si el índice está fuera de límites.
    /// ADVERTENCIA: No modifiques el terminador null.
    ///
    /// Parámetros:
    ///   - self: Puntero mutable a la instancia
    ///   - i: Índice del byte a acceder (base 0, no incluye el terminador null)
    ///
    /// Retorna:
    ///   - Referencia mutable al byte en la posición especificada
    ///
    /// Pánico:
    ///   - Si i >= longitud de la cadena (excluyendo el terminador null)
    pub fn atMutChecked(self: *Self, i: usize) *u8 {
        if (i >= self.len()) {
            @panic("String index out of bounds");
        }
        return self.inner.atMut(i);
    }

    /// Limpia el contenido de la cadena, dejándola vacía pero manteniendo el terminador null.
    /// La capacidad asignada se mantiene sin cambios.
    ///
    /// Parámetros:
    ///   - self: Puntero mutable a la instancia
    pub fn clear(self: *Self) void {
        self.inner.inner.shrinkRetainingCapacity(1);
        // Re-agregar el terminador null
        self.inner.inner.items[0] = 0;
    }
};

test "U8String and U8StringZ functionality" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    // Prueba de U8String
    var s = try U8String.init(alloc);
    defer s.deinit();

    try s.appendSlice(alloc, "Hello, ");
    try s.appendSlice(alloc, "World!");

    std.testing.expect(s.len() == 13);
    std.testing.expect(std.mem.eql(u8, s.toSlice(), "Hello, World!"));

    // Prueba de U8StringZ
    var sz = try U8StringZ.init(alloc);
    defer sz.deinit();

    try sz.appendSlice(alloc, "Hello, Z-string!");

    try std.testing.expect(std.mem.eql(u8, sz.toSlice(), "Hello, Z-string!"));
}
