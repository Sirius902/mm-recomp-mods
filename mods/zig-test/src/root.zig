const math = @import("math.zig");
const recomp = @import("recomp");

extern fn bruh() callconv(.c) f64;

fn onInit() linksection(recomp.callbackSection("*", "recomp_on_init")) callconv(.c) void {
    _ = recomp.printf("Hello from Zig! %f\n", math.atan2(bruh(), bruh()));
}

comptime {
    @export(&onInit, .{
        .name = "onInit",
        .linkage = .weak,
    });
}
