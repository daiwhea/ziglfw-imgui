const std = @import("std");
const builtin = @import("builtin");
const config = @import("zga-config");

// const gui_app = @import("app/main.zig");
const c = @import("c.zig").c;

// const pages = @import("app/pages/main.zig");
// const stockserver = @import("stockserver/main.zig");

const APP_ID = "ziglfw";

// var show_another_window = false;
const clear_color = c.ImVec4{ .x = 0.45, .y = 0.55, .z = 0.60, .w = 1.00 };

var allocator: std.mem.Allocator = undefined;
var thread_safe_allocator: std.mem.Allocator = undefined;
// we don't set window bg in each pages.
// because windowBg must  be settled before igBegin(), so it's set in user logic
var window_bg_has_set = false;
const glsl_version = "#version 150";
const MIN_WIDTH: c_int = 600;
const MIN_HEIGHT: c_int = 400;
pub fn main() !void {
    if (c.glfwInit() != c.GLFW_TRUE) {
        unreachable;
    }
    _ = c.glfwSetErrorCallback(glfw_error_callback);

    // GL 3.2 + GLSL 150

    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 3);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 2);
    c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE); // 3.2+ only
    if (builtin.os.tag == .macos) {
        c.glfwWindowHint(c.GLFW_OPENGL_FORWARD_COMPAT, c.GL_TRUE); // Required on Mac
    }
    // Create window with graphics context
    const window = c.glfwCreateWindow(1280, 720, "Dear ImGui GLFW+OpenGL3 example", null, null);
    std.debug.print("window: {any}\n", .{window});
    if (window == null) {
        unreachable;
    }
    c.glfwMakeContextCurrent(window);
    c.glfwSwapInterval(1); // Enable vsync

    if (c.gladLoadGLLoader(gladGetProcAddress) != 1) {
        @panic("Failed to initialise GLAD\n");
    }
    // Setup Dear ImGui context
    const context = c.igCreateContext(null);
    // _ = context;
    const ioptr = c.igGetIO();

    ioptr.*.ConfigFlags |= c.ImGuiConfigFlags_NavEnableKeyboard; // Enable Keyboard Controls
    ioptr.*.ConfigFlags |= c.ImGuiConfigFlags_NavEnableGamepad; // Enable Gamepad Controls

    // Setup Dear ImGui style
    c.igStyleColorsDark(null);

    // Setup Platform/Renderer backends
    _ = c.ImGui_ImplGlfw_InitForOpenGL(window, true);
    _ = c.ImGui_ImplOpenGL3_Init(glsl_version);

    // Our state
    var show_demo_window = true;
    var show_another_window = false;
    if (c.gladLoadGLLoader(gladGetProcAddress) != 1) {
        @panic("Failed to initialise GLAD\n");
    }
    // Main loop
    var f: f32 = 0.0;
    var counter: c_int = 0;
    const win_flag = c.ImGuiWindowFlags_AlwaysAutoResize | c.ImGuiWindowFlags_NoTitleBar | c.ImGuiWindowFlags_MenuBar;
    while (c.glfwWindowShouldClose(window) != c.GLFW_TRUE) {
        // Poll and handle events (inputs, window resize, etc.)
        // You can read the io.WantCaptureMouse, io.WantCaptureKeyboard flags to tell if dear imgui wants to use your inputs.
        // - When io.WantCaptureMouse is true, do not dispatch mouse input data to your main application, or clear/overwrite your copy of the mouse data.
        // - When io.WantCaptureKeyboard is true, do not dispatch keyboard input data to your main application, or clear/overwrite your copy of the keyboard data.
        // Generally you may always pass all inputs to dear imgui, and hide them from your application based on those two flags.
        c.glfwPollEvents();

        // Start the Dear ImGui frame
        c.ImGui_ImplOpenGL3_NewFrame();
        c.ImGui_ImplGlfw_NewFrame();
        c.igNewFrame();

        // // 1. Show the big demo window (Most of the sample code is in ImGui::ShowDemoWindow()! You can browse its code to learn more about Dear ImGui!).
        if (show_demo_window)
            c.igShowDemoWindow(&show_demo_window);

        // 2. Show a simple window that we create ourselves. We use a Begin/End pair to create a named window.
        {
            _ = c.igBegin("ziglfw", null, win_flag); // Create a window called "Hello, world!" and append into it.

            c.igText("This is some useful text."); // Display some text (you can use a format strings too)
            _ = c.igCheckbox("Demo Window", &show_demo_window); // Edit bools storing our window open/close state
            _ = c.igCheckbox("Another Window", &show_another_window);

            _ = c.igSliderFloat("float", &f, -180.0, 180.0, "%.0f deg", c.ImGuiSliderFlags_AlwaysClamp);
            // c.igSliderFloat("float", &f, 0.0, 1.0); // Edit 1 float using a slider from 0.0f to 1.0f
            // c.igColorEdit3("clear color", &clear_color); // Edit 3 floats representing a color

            if (c.igButton("Button", c.ImVec2{ .x = 0, .y = 0 })) { // Buttons return true when clicked (most widgets return true when edited/activated)
                counter += 1;
            }
            c.igSameLine(0, 0);
            c.igText("counter = %d", counter);

            c.igText("Application average %.3f ms/frame (%.1f FPS)", 1000.0 / ioptr.*.Framerate, ioptr.*.Framerate);
            c.igSeparator();
            c.igText("zig version: %s", builtin.zig_version_string);
            c.igEnd();
        }

        // 3. Show another simple window.
        if (show_another_window) {
            _ = c.igBegin("Another Window", &show_another_window, win_flag); // Pass a pointer to our bool variable (the window will have a closing button that will clear the bool when clicked)
            _ = c.igText("Hello from another window!");
            if (c.igButton("Close Me", c.ImVec2{ .x = 0, .y = 0 })) {
                show_another_window = false;
            }
            c.igEnd();
        }

        c.igRender();

        var display_w: i32 = 0;
        var display_h: i32 = 0;
        c.glfwGetFramebufferSize(window, &display_w, &display_h);
        c.glViewport(0, 0, display_w, display_h);
        // c.glClearColor(clear_color.x * clear_color.w, clear_color.y * clear_color.w, clear_color.z * clear_color.w, clear_color.w);
        c.glClearColor(clear_color.x, clear_color.y, clear_color.z, clear_color.w);
        c.glClear(c.GL_COLOR_BUFFER_BIT);
        c.ImGui_ImplOpenGL3_RenderDrawData(c.igGetDrawData());
        c.glfwSwapBuffers(window);
    }

    // Cleanup
    c.ImGui_ImplOpenGL3_Shutdown();
    c.ImGui_ImplGlfw_Shutdown();
    c.igDestroyContext(context);

    c.glfwDestroyWindow(window);
    c.glfwTerminate();
}

fn glfw_error_callback(err: c_int, description: [*c]const u8) callconv(.c) void {
    std.debug.print("GLFW Error {d}: {s}\n", .{ err, description });
}

fn gladGetProcAddress(procname: [*c]const u8) callconv(.c) ?*anyopaque {
    const proc = @intFromPtr(c.glfwGetProcAddress(procname));
    return @ptrFromInt(proc);
}
