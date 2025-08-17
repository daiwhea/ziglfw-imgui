const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addLibrary(.{
        .name = "vulkan-headers",
        .version = .{ .major = 1, .minor = 4, .patch = 0 },
        .linkage = .static,
        .root_module = b.createModule(.{
            .root_source_file = null,
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });

    inline for (.{ "vk_video", "vulkan" }) |subdir| {
        lib.installHeadersDirectory(b.path("include/" ++ subdir), subdir, .{});
    }
    b.installArtifact(lib);
}
