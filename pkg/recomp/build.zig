const std = @import("std");

pub fn build(b: *std.Build) void {
    const recomp = b.addModule("recomp", .{
        .root_source_file = b.path("src/root.zig"),
    });
    _ = recomp;
}
