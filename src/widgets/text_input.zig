const std = @import("std");
const rl = @import("raylib");

const U8StringZ = @import("../string.zig").U8StringZ;
const Location = @import("../location.zig").Location;

/// un widget para ingresar texto.
// El funcionamiento es el siguiente:
// - Cuando el widget está enfocado, captura la entrada de teclado.
// - Cada vez que se presiona una tecla, se agrega el carácter correspondiente al texto.
// - Si se presiona la tecla de retroceso, se elimina el último carácter del texto. (si esta vacio, no hace nada.)
pub const TextInput = struct {
    text: U8StringZ,
    font_size: i32,
    is_focused: bool, // esta focus si el usuario hizo click en el input
    default_text: U8StringZ,
    color: rl.Color, // color del texto

    // additional props.
    char_limit: usize, // limite de caracteres, si es null no hay limite

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator, options: struct {
        default_text: []const u8 = "?",
        font_size: i32 = 20,
        color: rl.Color = .white,
        char_limit: usize = 50,
    }) !Self {
        var self = Self{
            .text = try U8StringZ.initWithCapacity(allocator, options.char_limit),
            .font_size = options.font_size,
            .is_focused = false,
            .default_text = undefined,
            .color = options.color,
            .char_limit = options.char_limit,
        };
        errdefer self.text.deinit(allocator);
        self.default_text = try U8StringZ.initFromSlice(allocator, options.default_text);
        return self;
    }

    pub fn deinit(self: *Self, allocator: std.mem.Allocator) void {
        self.text.deinit(allocator);
        self.default_text.deinit(allocator);
    }

    pub fn update(self: *Self, location: Location) void {
        if (self.is_focused) {
            // Capturar entrada de texto
            const c = rl.getCharPressed();
            // Validar que sea un carácter ASCII válido (32-126 son caracteres imprimibles)
            if (c >= 32 and c <= 126 and self.text.len() < self.char_limit) {
                const chr = @as(u8, @intCast(c));
                self.text.put(chr) catch {}; // Si no se pueden agregar mas caracteres, ignorar. es criterio de diseño.
            }
            else if (rl.isKeyPressed(.backspace)) { // Manejar retroceso
                _ = self.text.pop();
            }
        }

        // Manejar foco (click)
        const mouse_pressed = rl.isMouseButtonPressed(rl.MouseButton.left);
        if (mouse_pressed) {
            self.is_focused = self.isHovered(location);
        }
    }

    fn isClicked(self: *const Self, location: Location) bool {
        const mouse_x = rl.getMouseX();
        const mouse_y = rl.getMouseY();
        const width = self.getWidth();
        const height = self.getHeight();
        const mouse_pressed = rl.isMouseButtonPressed(rl.MouseButton.left);
        return mouse_pressed and
            (mouse_x >= location.x()) and (mouse_x <= location.x() + width) and
            (mouse_y >= location.y()) and (mouse_y <= location.y() + height);
    }

    fn isHovered(self: *const Self, location: Location) bool {
        const mouse_x = rl.getMouseX();
        const mouse_y = rl.getMouseY();
        const width = self.getWidth();
        const height = self.getHeight();
        return (mouse_x >= location.x()) and (mouse_x <= location.x() + width) and
            (mouse_y >= location.y()) and (mouse_y <= location.y() + height);
    }

    pub fn draw(self: *const Self, location: Location) void {
        if (self.text.len() == 0 and !self.is_focused) {
            rl.drawText(self.default_text.toSlice(), location.x(), location.y(), self.font_size, .gray);
        } else {
            rl.drawText(self.text.toSlice(), location.x(), location.y(), self.font_size, self.color);
        }

        // Dibujar el cursor si está enfocado
        if (self.is_focused) {
            const text_width = rl.measureText(self.text.toSlice(), self.font_size);
            const cursor_x = location.x() + text_width + 2; // pequeño offset
            const thickness: i32 = if (@divTrunc(self.font_size, 10) < 2) 2 else @divTrunc(self.font_size, 10);
            const cursor_y = location.y() + self.font_size - thickness;
            const cursor_width: i32 = @divTrunc(self.font_size, 2); // ancho del guion _ estilo CMD
            rl.drawRectangle(cursor_x, cursor_y, cursor_width, thickness, self.color);
        }
    }

    pub fn getWidth(self: *const Self) i32 {
        if (self.text.len() == 0) {
            return rl.measureText(self.default_text.toSlice(), self.font_size);
        } else {
            return rl.measureText(self.text.toSlice(), self.font_size);
        }
    }

    pub fn getHeight(self: *const Self) i32 {
        return self.font_size;
    }
};
