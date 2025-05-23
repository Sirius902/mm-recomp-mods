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
