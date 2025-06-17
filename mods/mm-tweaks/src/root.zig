const std = @import("std");
const recomp = @import("recomp");
const c = @cImport({
    @cDefine("_LANGUAGE_C", {});
    @cInclude("global.h");
});

const allocator = recomp.raw_allocator;

var delay_frames: usize = 0;
var input_queue = std.ArrayList(c.Input).init(allocator);

fn pruneQueue() void {
    while (input_queue.items.len > delay_frames) {
        _ = input_queue.pop();
    }
}

export fn InputQueue_SetDelay(frames: usize) callconv(.C) void {
    input_queue.ensureTotalCapacity(frames) catch @panic("OOM");
    delay_frames = frames;
    pruneQueue();
}

export fn InputQueue_Push(input: ?*const c.Input) callconv(.C) void {
    pruneQueue();
    if (input_queue.items.len == delay_frames) {
        _ = input_queue.pop();
    }

    input_queue.insert(0, input.?.*) catch @panic("OOM");
}

export fn InputQueue_Pop(out: ?*c.Input) callconv(.C) bool {
    if (input_queue.items.len < delay_frames) {
        return false;
    }

    if (input_queue.pop()) |input| {
        out.?.* = input;
        return true;
    }

    return false;
}

const Notch = struct {
    stick_x: i8,
    stick_y: i8,
    angle: f64,
};

const max_axis = 85.0;

const notches = blk: {
    var ns: [8]Notch = undefined;

    for (&ns, 0..) |*notch, i| {
        const angle = @as(f64, @floatFromInt(i)) * (std.math.pi / 4.0);
        notch.* = .{
            .stick_x = std.math.round(max_axis * std.math.cos(angle)),
            .stick_y = std.math.round(max_axis * std.math.sin(angle)),
            .angle = angle,
        };
    }

    break :blk ns;
};

export fn VirtualNotches_Apply(input: ?*c.Input, degrees: f64) callconv(.C) void {
    const notch_activation_range = 0.9;

    const x = &input.?.cur.stick_x;
    const y = &input.?.cur.stick_y;

    const fx: f64 = @floatFromInt(x.*);
    const fy: f64 = @floatFromInt(y.*);

    const mag = std.math.sqrt(fx * fx + fy * fy) / max_axis;
    if (mag < notch_activation_range) {
        return;
    }

    const stick_angle = blk: {
        const angle = std.math.atan2(fy, fx);
        // Ensure stick angle is in [0, 2pi) to match notch angles.
        break :blk if (angle >= 0.0)
            angle
        else
            angle + 2.0 * std.math.pi;
    };

    const notch_size = std.math.degreesToRadians(degrees);

    for (&notches) |notch| {
        if (@abs(notch.angle - stick_angle) < notch_size * 0.5) {
            x.* = notch.stick_x;
            y.* = notch.stick_y;
            break;
        }
    }
}
