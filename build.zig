const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{}); // El target a compilar

    const optimize = b.standardOptimizeOption(.{}); // Opciones de optimización

    // dependencia de raylib-zig, explicita en build.zig.zon
    const raylib_dep = b.dependency("raylib_zig", .{
        .target = target,
        .optimize = optimize,
    });

    // Defino modulos
    const raylib = raylib_dep.module("raylib"); // main raylib module
    const raygui = raylib_dep.module("raygui"); // raygui module
    const raylib_artifact = raylib_dep.artifact("raylib"); // raylib C library

    // Módulo principal del proyecto, definido en src/root.zig
    const mod = b.addModule("pong_zig", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .imports = &.{
            .{ .name = "raylib", .module = raylib },
            .{ .name = "raygui", .module = raygui },
        },
    });

    // defino exe que compila el proyecto
    const exe = b.addExecutable(.{
        .name = "pong_zig",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),

            .target = target,
            .optimize = optimize,

            .imports = &.{
                .{ .name = "pong_zig", .module = mod },
                .{ .name = "raylib", .module = raylib },
            },
        }),
    });

    // linkeo raylib
    exe.linkLibrary(raylib_artifact);
    exe.root_module.addImport("raylib", raylib);
    exe.root_module.addImport("raygui", raygui);

    // instalo exe en zig-out/bin
    b.installArtifact(exe);

    // -- EXTRA --

    // Defino opcion para correr la app. aparece con `zig build --help`
    const run_step = b.step("run", "Run the app");

    // Defino comando para ejecutar el exe
    const run_cmd = b.addRunArtifact(exe);
    // El step "run" depende del step de correr el exe
    run_step.dependOn(&run_cmd.step);

    // Hago que el comando run solo se pueda ejecutar despues de instalar
    run_cmd.step.dependOn(b.getInstallStep());

    // Agrego argumentos al comando run si se pasaron
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // Defino tests del modulo principal (src/root.zig)
    const mod_tests = b.addTest(.{
        .root_module = mod,
    });

    // Comando para correr los tests del modulo principal (src/root.zig)
    const run_mod_tests = b.addRunArtifact(mod_tests);

    // Comando para correr los tests del exe (src/main.zig)
    const exe_tests = b.addTest(.{
        .root_module = exe.root_module,
    });

    // Creo comando para correr los tests del exe (src/main.zig)
    const run_exe_tests = b.addRunArtifact(exe_tests);

    // Defino step "test" que corre todos los tests
    const test_step = b.step("test", "Run tests");

    // El step "test" depende de correr los tests del modulo principal y del exe
    test_step.dependOn(&run_mod_tests.step);
    test_step.dependOn(&run_exe_tests.step);
}
