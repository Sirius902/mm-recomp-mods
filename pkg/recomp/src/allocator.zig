const std = @import("std");
const utils = @import("utils.zig");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const mem = std.mem;

/// Asserts allocations are within `@alignOf(std.c.max_align_t)` and directly
/// calls `malloc`/`free`. Does not attempt to utilize `malloc_usable_size`.
/// This allocator is safe to use as the backing allocator with
/// `ArenaAllocator` for example and is more optimal in such a case than
/// `c_allocator`.
pub const raw_allocator: Allocator = .{
    .ptr = undefined,
    .vtable = &raw_allocator_vtable,
};
const raw_allocator_vtable: Allocator.VTable = .{
    .alloc = rawRecompAlloc,
    .resize = rawRecompResize,
    .remap = rawRecompRemap,
    .free = rawRecompFree,
};

fn rawRecompAlloc(
    context: *anyopaque,
    len: usize,
    alignment: mem.Alignment,
    return_address: usize,
) ?[*]u8 {
    _ = context;
    _ = return_address;
    assert(alignment.compare(.lte, comptime .fromByteUnits(@alignOf(std.c.max_align_t))));
    // Note that this pointer cannot be aligncasted to max_align_t because if
    // len is < max_align_t then the alignment can be smaller. For example, if
    // max_align_t is 16, but the user requests 8 bytes, there is no built-in
    // type in C that is size 8 and has 16 byte alignment, so the alignment may
    // be 8 bytes rather than 16. Similarly if only 1 byte is requested, malloc
    // is allowed to return a 1-byte aligned pointer.
    return @ptrCast(utils.alloc(len));
}

fn rawRecompResize(
    context: *anyopaque,
    memory: []u8,
    alignment: mem.Alignment,
    new_len: usize,
    return_address: usize,
) bool {
    _ = context;
    _ = memory;
    _ = alignment;
    _ = new_len;
    _ = return_address;
    return false;
}

fn rawRecompRemap(
    context: *anyopaque,
    memory: []u8,
    alignment: mem.Alignment,
    new_len: usize,
    return_address: usize,
) ?[*]u8 {
    defer rawRecompFree(context, memory, alignment, return_address);
    if (rawRecompAlloc(context, new_len, alignment, return_address)) |new_memory| {
        @memcpy(new_memory[0..new_len], memory);
        return @ptrCast(new_memory);
    } else {
        return null;
    }
}

fn rawRecompFree(
    context: *anyopaque,
    memory: []u8,
    alignment: mem.Alignment,
    return_address: usize,
) void {
    _ = context;
    _ = alignment;
    _ = return_address;
    utils.free(memory.ptr);
}
