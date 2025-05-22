const modding = @import("modding.zig");

pub noinline fn alloc(size: c_ulong) linksection(modding.importSection("*")) callconv(.C) *anyopaque {
    _ = size;
    unreachable;
}

comptime {
    @export(&alloc, .{
        .name = "recomp_alloc",
        .linkage = .weak,
    });
}

pub noinline fn free(memory: *anyopaque) linksection(modding.importSection("*")) callconv(.C) void {
    _ = memory;
    unreachable;
}

comptime {
    @export(&free, .{
        .name = "recomp_free",
        .linkage = .weak,
    });
}

pub noinline fn printf(fmt: [*:0]const u8, ...) linksection(modding.importSection("*")) callconv(.C) c_int {
    _ = fmt;
    unreachable;
}

comptime {
    @export(&printf, .{
        .name = "recomp_printf",
        .linkage = .weak,
    });
}
