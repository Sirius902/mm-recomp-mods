const modding = @import("modding.zig");

/// Reads a config value of the specified type and name for the mod that called these functions.
/// These correspond to the config schema provided in the mod's manifest.
pub noinline fn get_config_u32(key: [*:0]const u8) linksection(modding.import("*")) callconv(.C) c_ulong {
    _ = key;
    unreachable;
}

comptime {
    @export(&get_config_u32, .{
        .name = "recomp_get_config_u32",
        .linkage = .weak,
    });
}

/// Reads a config value of the specified type and name for the mod that called these functions.
/// These correspond to the config schema provided in the mod's manifest.
pub noinline fn get_config_double(key: [*:0]const u8) linksection(modding.import("*")) callconv(.C) f64 {
    _ = key;
    unreachable;
}

comptime {
    @export(&get_config_double, .{
        .name = "recomp_get_config_double",
        .linkage = .weak,
    });
}

/// Reads a config value of the specified type and name for the mod that called these functions.
/// These correspond to the config schema provided in the mod's manifest.
pub noinline fn get_config_string(key: [*:0]const u8) linksection(modding.import("*")) callconv(.C) [*:0]u8 {
    _ = key;
    unreachable;
}

comptime {
    @export(&get_config_string, .{
        .name = "recomp_get_config_string",
        .linkage = .weak,
    });
}

/// Frees a value returned by `recomp_get_config_string`. MUST be called to prevent a memory leak.
pub noinline fn free_config_string(str: [*:0]u8) linksection(modding.import("*")) callconv(.C) void {
    _ = str;
    unreachable;
}

comptime {
    @export(&free_config_string, .{
        .name = "recomp_free_config_string",
        .linkage = .weak,
    });
}

/// Gets the version of the mod that called this function. Writes the mod's version numbers into the provided pointers.
pub noinline fn get_mod_version(major: *c_ulong, minor: *c_ulong, patch: *c_ulong) linksection(modding.import("*")) callconv(.C) void {
    _ = major;
    _ = minor;
    _ = patch;
    unreachable;
}

comptime {
    @export(&get_mod_version, .{
        .name = "recomp_get_mod_version",
        .linkage = .weak,
    });
}

/// Swaps to using a different file. The new save file will be located at `<mod id>/<filename>.bin` in the normal saves folder.
/// Don't include `.bin` in the provided filename.
/// Be careful calling this function during normal gameplay as the game won't be aware that any currently loaded save data is outdated.
pub noinline fn change_save_file(filename: [*:0]const u8) linksection(modding.import("*")) callconv(.C) void {
    _ = filename;
    unreachable;
}

comptime {
    @export(&change_save_file, .{
        .name = "recomp_change_save_file",
        .linkage = .weak,
    });
}

/// Returns a UTF-8 encoded zero-terminated string containing the absolute path to the current save file.
/// The return type is an unsigned char pointer to indicate the UTF-8 encoding.
/// `recomp_free` (found in `recomputils.h`) MUST be called on the return value of this when the value is no longer in use to prevent a memory leak.
pub noinline fn get_save_file_path() linksection(modding.import("*")) callconv(.C) [*:0]const u8 {
    unreachable;
}

comptime {
    @export(&get_save_file_path, .{
        .name = "recomp_get_save_file_path",
        .linkage = .weak,
    });
}
