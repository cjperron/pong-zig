const std = @import("std");

const rl = @import("raylib");

pub const Widget = union(enum) {
    text: Text,
    underlined_text: UnderlinedText,
    button: Button,
    menu_selection: MenuSelection,

    pub fn initText(options: struct {
        x: i32,
        y: i32,
        text: [:0]const u8,
        font_size: i32 = 20,
        color: rl.Color = rl.Color.white,
        update_condition: ?*const fn () bool = null,
        update_action: ?*const fn (*Text) void = null,
    }) Widget {
        return Widget{ .text = Text.init(.{
            .x = options.x,
            .y = options.y,
            .text = options.text,
            .font_size = options.font_size,
            .color = options.color,
            .update_condition = options.update_condition,
            .update_action = options.update_action,
        }) };
    }

    pub fn initUnderlinedText(options: struct {
        inner_text: Text,
        underline_size: i32 = 5,
    }) Widget {
        return Widget{ .underlined_text = UnderlinedText.init(.{ .inner_text = options.inner_text, .underline_size = options.underline_size }) };
    }

    pub fn initButton(options: struct {
        label: [:0]const u8,
        font_size: i32,
        color: rl.Color,
        bg_color: rl.Color,
        x: i32,
        y: i32,
        width: i32,
        height: i32,
        action: *const fn () void,
    }) Widget {
        return Widget{ .button = Button{
            .label = options.label,
            .font_size = options.font_size,
            .color = options.color,
            .bg_color = options.bg_color,
            .x = options.x,
            .y = options.y,
            .width = options.width,
            .height = options.height,
            .action = options.action,
        } };
    }

    pub fn initMenuSelection(options: struct {
        buttons: []Button,
        selected_index: usize = 0,
    }) Widget {
        return Widget{ .menu_selection = MenuSelection{
            .buttons = options.buttons,
            .selected_index = options.selected_index,
        } };
    }

    pub fn draw(self: @This()) void {
        switch (self) {
            .text => |t| t.draw(),
            .underlined_text => |ut| ut.draw(),
            .button => |b| b.draw(),
            .menu_selection => |ms| ms.draw(),
        }
    }

    pub fn update(self: *@This()) void {
        switch (self.*) {
            .text => |*t| t.update(),
            .underlined_text => |*ut| ut.update(),
            .button => {},
            .menu_selection => |*ms| ms.update(),
        }
    }
};

pub const Text = struct {
    x: i32,
    y: i32,
    text: [:0]const u8,
    font_size: i32,
    color: rl.Color,
    // Logica de actualizacion
    update_condition: ?*const fn () bool,
    update_action: ?*const fn (*@This()) void,

    pub fn init(
        options: struct {
            x: i32,
            y: i32,
            text: [:0]const u8,
            font_size: i32 = 20,
            color: rl.Color = rl.Color.white,
            // En el caso que se tenga que actualizar el texto, hay que manejar con logica custom.
            update_condition: ?*const fn () bool = null, // Si el texto se actualiza, esto NO es null
            // Si actualizamos el widget, tenemos que sobrescribirlo.
            // Naturalmente, para lograrlo de la forma mas clean, lo mas sencillo es modificarla por referencia, y darle el poder al usuario de decir que modificar.
            update_action: ?*const fn (*Text) void = null,
        },
    ) Text {
        return Text{ .x = options.x, .y = options.y, .text = options.text, .font_size = options.font_size, .color = options.color, .update_condition = options.update_condition, .update_action = options.update_action };
    }

    pub fn update(self: *@This()) void {
        // Placeholder for update logic if needed in the future
        if (self.update_condition) |condition| {
            if (condition()) {
                if (self.update_action) |action| {
                    action(self);
                }
            }
        }
    }

    pub fn draw(self: @This()) void {
        rl.drawText(self.text, self.x, self.y, self.font_size, self.color);
    }
};

pub const UnderlinedText = struct {
    inner_text: Text,
    underline_size: i32,

    pub fn init(options: struct { inner_text: Text, underline_size: i32 = 5 }) UnderlinedText {
        return UnderlinedText{ .inner_text = options.inner_text, .underline_size = options.underline_size };
    }

    pub fn draw(self: UnderlinedText) void {
        self.inner_text.draw();
        const text_width = rl.measureText(self.inner_text.text, self.inner_text.font_size);
        const offset = @max(2, @divTrunc(self.inner_text.font_size, 20)); // Muy cerca, proporcional
        const line_y = self.inner_text.y + self.inner_text.font_size - @divTrunc(self.inner_text.font_size, 5) + offset;
        rl.drawRectangle(self.inner_text.x, line_y, text_width, self.underline_size, self.inner_text.color);
    }

    pub fn update(self: *UnderlinedText) void {
        self.inner_text.update();
        // TODO: if inner_text updateable, update line width along with color.
    }
};

pub const Button = struct {
    label: [:0]const u8,
    font_size: i32,
    color: rl.Color,
    bg_color: rl.Color,
    x: i32,
    y: i32,
    width: i32,
    height: i32,

    action: *const fn () void,

    pub fn isClicked(self: Button) bool {
        const mouseX = rl.getMouseX();
        const mouseY = rl.getMouseY();
        const mousePressed = rl.isMouseButtonPressed(rl.MouseButton.left);

        return mousePressed and
            (mouseX >= self.x) and (mouseX <= self.x + self.width) and
            (mouseY >= self.y) and (mouseY <= self.y + self.height);
    }

    pub fn draw(self: Button) void {
        // Draw button background
        rl.drawRectangle(self.x, self.y, self.width, self.height, self.bg_color);

        // Calculate text position to center it in the button
        const textWidth = rl.measureText(self.label, self.font_size);
        const textX = self.x + @divTrunc((self.width - textWidth), 2);
        const textY = self.y + @divTrunc((self.height - self.font_size), 2);

        // Draw button label
        rl.drawText(self.label, textX, textY, self.font_size, self.color);
    }
};

/// Ayudita para tener un array de botones con layout vertical u horizontal.
pub const MenuSelection = struct {
    buttons: []Button,
    selected_index: usize,

    pub fn update(self: *MenuSelection) void {
        for (self.buttons, 0..) |*button, index| {
            if (button.isClicked()) {
                self.selected_index = index;
                button.action();
            }
        }
    }

    pub fn draw(self: MenuSelection) void {
        for (self.buttons) |button| {
            button.draw();
        }
    }
};
