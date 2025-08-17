const builtin = @import("builtin");
const std = @import("std");

comptime {
    const supported_zig = std.SemanticVersion.parse("0.12.0-dev.2063+804cee3b9") catch unreachable;
    const order = builtin.zig_version.order(supported_zig);
    if (order == .lt) {
        @compileError(std.fmt.comptimePrint("unsupported Zig version ({}). Required Zig version 2024.1.0-mach: https://machengine.org/about/nominated-zig/#202410-mach", .{builtin.zig_version}));
    }
}

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    const gui_exe = b.addExecutable(.{
        .name = "ziglfw",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    installAll(b, gui_exe, target, optimize);
    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    b.installArtifact(gui_exe);
    // This *creates* a Run step in the build graph, to be executed when another
    // step is evaluated that depends on it. The next line below will establish
    // such a dependency.
    const run_cmd = b.addRunArtifact(gui_exe);

    // By making the run step depend on the install step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    // This is not necessary, however, if the application depends on other installed
    // files, this ensures they will be present and in the expected location.
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}

pub fn installGL(b: *std.Build, lib: *std.Build.Step.Compile) void {
    const gl = b.createModule(.{
        .root_source_file = .{ .path = libs_path ++ "/gl41.zig" },
    });
    lib.root_module.addImport("gl", gl);
}

pub fn installAll(b: *std.Build, lib: *std.Build.Step.Compile, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) void {
    installGlfw(b, lib, target, optimize);
    installGlad(b, lib);
    installImGui(b, lib);
}

pub fn installGlfw(b: *std.Build, lib: *std.Build.Step.Compile, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) void {
    const glfw_dep = b.dependency("glfw", .{
        .target = target,
        .optimize = optimize,
    });
    lib.root_module.linkLibrary(glfw_dep.artifact("glfw"));
}

pub fn installGlad(b: *std.Build, lib: *std.Build.Step.Compile) void {
    const KHR_home = libs_path ++ "/KHR";
    const glad_home = libs_path ++ "/glad";

    const glad_c_file = glad_home ++ "/glad.c";

    lib.addIncludePath(b.path(libs_path));
    lib.addIncludePath(b.path(KHR_home));
    lib.addIncludePath(b.path(glad_home));

    // lib.installHeadersDirectory(KHR_home, "KHR");

    // lib.installHeadersDirectory(glad_home, "glad");

    lib.addCSourceFile(.{
        .file = b.path(glad_c_file),
        .flags = &[_][]const u8{
            // "-std=c++11",
            "-fno-sanitize=undefined",
            "-ffunction-sections",
        },
    });
}

pub fn installImGui(b: *std.Build, lib: *std.Build.Step.Compile) void {
    const cimgui_path = libs_path ++ "/cimgui/cimgui-master/";
    const cimgui_impl_path = libs_path ++ "/cimgui/cimgui-master/generator/output/";
    const imgui_path = libs_path ++ "/cimgui/cimgui-master/imgui/";
    const imgui_backends_path = libs_path ++ "/cimgui/cimgui-master/imgui/backends/";

    const cimgui_cpp_file = libs_path ++ "/cimgui/cimgui_unity.cpp";

    lib.linkLibC();
    lib.linkLibCpp();
    lib.addIncludePath(b.path(cimgui_path));
    lib.addIncludePath(b.path(cimgui_impl_path));
    lib.addIncludePath(b.path(imgui_path));
    lib.addIncludePath(b.path(imgui_backends_path));
    // lib.root_module.addCMacro("__kernel_ptr_semantics", "");
    lib.root_module.addCMacro("CIMGUI_USE_GLFW", "1");
    lib.root_module.addCMacro("CIMGUI_USE_OPENGL3", "1");

    lib.addCSourceFile(.{
        .file = b.path(cimgui_cpp_file),
        .flags = &[_][]const u8{
            // "-std=c++11",
            "-fno-sanitize=undefined",
            "-ffunction-sections",
        },
    });
}

const sep = std.fs.path.sep_str;
const basepath = ".";
const libs_path = basepath ++ sep ++ "libs";
