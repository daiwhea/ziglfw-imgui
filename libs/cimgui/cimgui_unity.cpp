#define IMGUI_DISABLE_OBSOLETE_FUNCTIONS 1
#define IMGUI_DISABLE_OBSOLETE_KEYIO 1
#define CIMGUI_USE_GLFW 1
#define CIMGUI_USE_OPENGL3 1
#define IMGUI_IMPL_API extern "C"

#ifndef IMGUI_DOCKING
#include "cimgui-master/imgui/imgui.cpp"
#include "cimgui-master/imgui/imgui_widgets.cpp"
#include "cimgui-master/imgui/imgui_tables.cpp"
#include "cimgui-master/imgui/imgui_draw.cpp"
#include "cimgui-master/imgui/backends/imgui_impl_opengl3.cpp"
#include "cimgui-master/imgui/backends/imgui_impl_glfw.cpp"
#include "cimgui-master/imgui/imgui_demo.cpp"
#include "cimgui-master/cimgui.cpp"
#endif
#ifdef IMGUI_DOCKING
#include "cimgui-docking/imgui/imgui.cpp"
#include "cimgui-docking/imgui/imgui_widgets.cpp"
#include "cimgui-docking/imgui/imgui_tables.cpp"
#include "cimgui-docking/imgui/imgui_draw.cpp"
#include "cimgui-docking/imgui/backends/imgui_impl_opengl3.cpp"
#include "cimgui-docking/imgui/backends/imgui_impl_glfw.cpp"
#include "cimgui-docking/imgui/imgui_demo.cpp"
#include "cimgui-docking/cimgui.cpp"
#endif