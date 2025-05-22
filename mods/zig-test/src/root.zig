const recomp = @import("recomp");

// FUTURE(Sirius902) `PlayState` does not work with translate-c because of
// bitfields in `gbi.h`.
// https://github.com/ziglang/zig/issues/1499

fn onInit() linksection(recomp.callbackSection("*", "recomp_on_init")) callconv(.C) void {
    _ = recomp.printf("Hello from Zig!\n");
}

comptime {
    @export(&onInit, .{
        .name = "onInit",
        .linkage = .weak,
    });
}
