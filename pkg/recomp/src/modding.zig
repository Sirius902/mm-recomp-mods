pub fn importSection(comptime mod: []const u8) []const u8 {
    comptime {
        return ".recomp_import." ++ mod;
    }
}

pub fn callbackSection(comptime mod: []const u8, comptime event: []const u8) []const u8 {
    comptime {
        return ".recomp_callback." ++ mod ++ ":" ++ event;
    }
}
