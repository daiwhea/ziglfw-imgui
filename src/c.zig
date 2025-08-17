/// This c.zig will import all the c/cpp functions/structs/enums.
pub const c = @cImport({
    @cDefine("CIMGUI_DEFINE_ENUMS_AND_STRUCTS", "");
    // we use glad to load opengl
    @cDefine("IMGUI_IMPL_OPENGL_LOADER_CUSTOM", "");
    @cDefine("IMGUI_DISABLE_DEBUG_TOOLS", "1");
    // @cDefine("GLFW_INCLUDE_NONE", "1");

    // attention the order of glad/glfw. we want to use glad as opengl loader, so it goes ahead glfw!
    @cInclude("glad/glad.h");
    @cInclude("GLFW/glfw3.h");

    @cInclude("cimgui.h");
    @cInclude("cimgui_impl.h");
});
