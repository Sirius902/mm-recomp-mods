const modding = @import("modding.zig");

/// Reads a config value of the specified type and name for the mod that called these functions.
/// These correspond to the config schema provided in the mod's manifest.
pub noinline fn getConfigU32(key: [*:0]const u8) linksection(modding.importSection("*")) callconv(.c) c_ulong {
    _ = key;
    unreachable;
}

comptime {
    @export(&getConfigU32, .{
        .name = "recomp_get_config_u32",
        .linkage = .weak,
    });
}

/// Reads a config value of the specified type and name for the mod that called these functions.
/// These correspond to the config schema provided in the mod's manifest.
pub noinline fn getConfigDouble(key: [*:0]const u8) linksection(modding.importSection("*")) callconv(.c) f64 {
    _ = key;
    unreachable;
}

comptime {
    @export(&getConfigDouble, .{
        .name = "recomp_get_config_double",
        .linkage = .weak,
    });
}

/// Reads a config value of the specified type and name for the mod that called these functions.
/// These correspond to the config schema provided in the mod's manifest.
pub noinline fn getConfigString(key: [*:0]const u8) linksection(modding.importSection("*")) callconv(.c) [*:0]u8 {
    _ = key;
    unreachable;
}

comptime {
    @export(&getConfigString, .{
        .name = "recomp_get_config_string",
        .linkage = .weak,
    });
}

/// Frees a value returned by `recomp_get_config_string`. MUST be called to prevent a memory leak.
pub noinline fn freeConfigString(str: [*:0]u8) linksection(modding.importSection("*")) callconv(.c) void {
    _ = str;
    unreachable;
}

comptime {
    @export(&freeConfigString, .{
        .name = "recomp_free_config_string",
        .linkage = .weak,
    });
}

/// Gets the version of the mod that called this function. Writes the mod's version numbers into the provided pointers.
pub noinline fn getModVersion(major: *c_ulong, minor: *c_ulong, patch: *c_ulong) linksection(modding.importSection("*")) callconv(.c) void {
    _ = major;
    _ = minor;
    _ = patch;
    unreachable;
}

comptime {
    @export(&getModVersion, .{
        .name = "recomp_get_mod_version",
        .linkage = .weak,
    });
}

/// Swaps to using a different file. The new save file will be located at `<mod id>/<filename>.bin` in the normal saves folder.
/// Don't include `.bin` in the provided filename.
/// Be careful calling this function during normal gameplay as the game won't be aware that any currently loaded save data is outdated.
pub noinline fn changeSaveFile(filename: [*:0]const u8) linksection(modding.importSection("*")) callconv(.c) void {
    _ = filename;
    unreachable;
}

comptime {
    @export(&changeSaveFile, .{
        .name = "recomp_change_save_file",
        .linkage = .weak,
    });
}

/// Returns a UTF-8 encoded zero-terminated string containing the absolute path to the current save file.
/// The return type is an unsigned char pointer to indicate the UTF-8 encoding.
/// `recomp_free` (found in `recomputils.h`) MUST be called on the return value of this when the value is no longer in use to prevent a memory leak.
pub noinline fn getSaveFilePath() linksection(modding.importSection("*")) callconv(.c) [*:0]const u8 {
    unreachable;
}

comptime {
    @export(&getSaveFilePath, .{
        .name = "recomp_get_save_file_path",
        .linkage = .weak,
    });
}
