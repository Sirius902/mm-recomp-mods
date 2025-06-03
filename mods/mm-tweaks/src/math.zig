const std = @import("std");

// Use lookup table for `std.math.atan2` as trying to use it at runtime will
// generate a `c.un.d` instruction which the recompiler does not implement
// right now.
const atan2_lut_len = std.math.maxInt(i8) + 1;
const atan2_lut = blk: {
    @setEvalBranchQuota(1_000_000);
    var lut: [atan2_lut_len * atan2_lut_len]f64 = undefined;

    for (0..lut.len) |i| {
        const y = i / atan2_lut_len;
        const x = i % atan2_lut_len;

        const fy: f64 = @floatFromInt(y);
        const fx: f64 = @floatFromInt(x);

        lut[i] = std.math.atan2(fy, fx);
    }

    break :blk lut;
};

pub fn atan2(y: i8, x: i8) f64 {
    const abs_x = @as(usize, @abs(@max(x, -std.math.maxInt(i8))));
    const abs_y = @as(usize, @abs(@max(y, -std.math.maxInt(i8))));

    const angle = atan2_lut[abs_y * atan2_lut_len + abs_x];
    if (x < 0 and y >= 0) {
        return std.math.pi - angle;
    } else if (x < 0 and y < 0) {
        return angle - std.math.pi;
    } else if (x >= 0 and y < 0) {
        return -angle;
    } else {
        return angle;
    }
}
