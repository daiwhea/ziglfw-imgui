This is just a demo for requesting help from others.

With zig version above zig-0.15.0.dev-1254, this demo fails to build. It's discussed here: https://github.com/ziglang/zig/issues/24883


This demo builds with zig-macos-x86_64-0.15.0-dev.383+927f233ff


But it fails with zig-x86_64-macos-0.15.0-dev.1254/1380/1552/1654


Although it won't be fixed soon, but we can make it works with the latest zig version by adding the following steps:

1. rm -rf .zig-cache
2. zig build
3. search for `IO: ImGuiIO = @import("std").mem.zeroes(ImGuiIO),` in `.zig-cache/o/ecd66b9217c5735cf7efb9cb0658b30d/cimport.zig` and replace with `IO: ImGuiIO = undefined, //@import("std").mem.zeroes(ImGuiIO),`
4. zig build will work now
