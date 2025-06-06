const std = @import("std");
const ZigLibDir = @import("build/ZigLibDir.zig");

pub fn build(b: *std.Build) !void {
    const query: std.Target.Query = .{
        .cpu_arch = .mips,
        .os_tag = .freestanding,
        .abi = .none,
        .cpu_model = .{ .explicit = &std.Target.mips.cpu.mips2 },
        .cpu_features_add = std.Target.mips.featureSet(&.{.fpxx}),
    };
    const target = b.resolveTargetQuery(query);
    const optimize = b.standardOptimizeOption(.{});

    const compiler_rt_obj = try compilerRtObj(b, target, optimize);

    const mod_opt = b.option([]const u8, "mod", "The mod to build.");
    if (mod_opt) |mod| {
        var mod_dir = try b.build_root.handle.openDir(b.pathJoin(&[_][]const u8{ "mods", mod }), .{});
        defer mod_dir.close();

        try buildMod(b, target, optimize, compiler_rt_obj, mod, &mod_dir);
    } else {
        var mods_dir = try b.build_root.handle.openDir("mods", .{ .iterate = true });
        defer mods_dir.close();

        var it = mods_dir.iterate();
        while (try it.next()) |entry| {
            if (entry.kind == .directory) {
                var entry_dir = try mods_dir.openDir(entry.name, .{});
                defer entry_dir.close();

                try buildMod(b, target, optimize, compiler_rt_obj, entry.name, &entry_dir);
            }
        }
    }
}

/// Creates object file for custom compiler_rt that avoids instructions not supported by recomp.
fn compilerRtObj(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
) !*std.Build.Step.Compile {
    const zig_lib_dir = try ZigLibDir.create(b);

    const write_src = b.addWriteFiles();
    _ = write_src.addCopyDirectory(
        try zig_lib_dir.getLibPath().join(b.allocator, "compiler_rt"),
        "compiler_rt/compiler_rt",
        .{},
    );
    const root_source_file = write_src.addCopyFile(
        b.path("build/compiler_rt.zig"),
        "compiler_rt/compiler_rt.zig",
    );

    const root_module = b.createModule(.{
        .root_source_file = root_source_file,
        .target = target,
        .optimize = optimize,
        .link_libc = false,
        .link_libcpp = false,
        .single_threaded = true,
        .strip = true,
        .unwind_tables = .none,
        .stack_protector = false,
        .stack_check = false,
        .sanitize_c = false,
        .sanitize_thread = false,
        .fuzz = false,
        .valgrind = false,
        .pic = false,
        .red_zone = false,
        .omit_frame_pointer = true,
        .error_tracing = false,
    });

    const obj = b.addObject(.{
        .name = "compiler_rt",
        .root_module = root_module,
    });
    obj.step.dependOn(&write_src.step);

    return obj;
}

fn buildMod(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    compiler_rt_obj: *std.Build.Step.Compile,
    name: []const u8,
    dir: *std.fs.Dir,
) !void {
    var src_dir = try dir.openDir("src", .{ .iterate = true });
    defer src_dir.close();

    const root_source_file: ?std.Build.LazyPath = blk: {
        const root_zig = "root.zig";
        if (src_dir.access(root_zig, .{})) {
            const path = src_dir.realpathAlloc(b.allocator, root_zig) catch @panic("OOM");
            break :blk .{ .cwd_relative = path };
        } else |_| {
            break :blk null;
        }
    };

    const exe_mod = b.createModule(.{
        .root_source_file = root_source_file,
        .target = target,
        .optimize = optimize,
        .link_libc = false,
        .link_libcpp = false,
        .single_threaded = true,
        .strip = true,
        .unwind_tables = .none,
        .stack_protector = false,
        .stack_check = false,
        .sanitize_c = false,
        .sanitize_thread = false,
        .fuzz = false,
        .valgrind = false,
        .pic = false,
        .red_zone = false,
        .omit_frame_pointer = true,
        .error_tracing = false,
    });

    if (root_source_file) |_| {
        exe_mod.addImport("recomp", b.dependency("recomp", .{}).module("recomp"));
    }

    const c_flags = [_][]const u8{
        "-G0",
        "-mno-check-zero-division",
        "-fno-unsafe-math-optimizations",
        "-fno-builtin-memset",
        "-Wall",
        "-Wextra",
        "-Wno-incompatible-library-redeclaration",
        "-Wno-unused-parameter",
        "-Wno-unknown-pragmas",
        "-Wno-unused-variable",
        "-Wno-missing-braces",
        "-Wno-unsupported-floating-point-opt",
        "-Werror=section",
    };

    const cpp_flags = [_][]const u8{
        "-D_LANGUAGE_C",
        "-DMIPS",
        "-DF3DEX_GBI_2",
        "-DF3DEX_GBI_PL",
        "-DGBI_DOWHILE",
    };

    const flags = c_flags ++ cpp_flags;

    var it = src_dir.iterate();
    while (try it.next()) |entry| {
        if (entry.kind == .file and std.mem.eql(u8, std.fs.path.extension(entry.name), ".c")) {
            const path = src_dir.realpathAlloc(b.allocator, entry.name) catch @panic("OOM");

            exe_mod.addCSourceFile(.{
                .file = .{ .cwd_relative = path },
                .flags = &flags,
                .language = .c,
            });
        }
    }

    const include_paths = [_][]const u8{
        "include",
        "include/dummy_headers",
        "mm-decomp/include",
        "mm-decomp/src",
        "mm-decomp/extracted/n64-us",
        "mm-decomp/include/libc",
    };

    for (include_paths) |path| {
        exe_mod.addIncludePath(b.path(path));
    }

    const exe_obj = b.addObject(.{
        .name = "mod",
        .root_module = exe_mod,
    });

    const link_elf = b.addSystemCommand(&[_][]const u8{ "ld.lld", "--nostdlib" });
    link_elf.addPrefixedFileArg("--script=", b.path("mod.ld"));
    link_elf.addArgs(&[_][]const u8{
        "--unresolved-symbols=ignore-all",
        "--emit-relocs",
        "--no-nmagic",
        "--entry=0",
    });
    const map_path = link_elf.addPrefixedOutputFileArg("--Map=", "mod.map");
    const elf_path = link_elf.addPrefixedOutputFileArg("--output=", "mod.elf");
    link_elf.addFileArg(exe_obj.getEmittedBin());

    // Link compiler_rt if the mod contains Zig source.
    if (root_source_file) |_| {
        link_elf.addFileArg(compiler_rt_obj.getEmittedBin());
        link_elf.step.dependOn(&compiler_rt_obj.step);
    }

    link_elf.step.dependOn(&exe_obj.step);

    const install_elf = b.addInstallBinFile(
        elf_path,
        b.pathJoin(&[_][]const u8{ name, "mod.elf" }),
    );
    install_elf.step.dependOn(&link_elf.step);

    const install_map = b.addInstallBinFile(
        map_path,
        b.pathJoin(&[_][]const u8{ name, "mod.map" }),
    );
    install_map.step.dependOn(&link_elf.step);

    const mod_toml_path = dir.realpathAlloc(b.allocator, "mod.toml") catch @panic("OOM");

    const mod_tool_step = b.addSystemCommand(&[_][]const u8{"RecompModTool"});
    mod_tool_step.addFileArg(.{ .cwd_relative = mod_toml_path });
    mod_tool_step.addDirectoryArg(.{ .cwd_relative = b.getInstallPath(.bin, name) });
    mod_tool_step.step.dependOn(&install_elf.step);
    mod_tool_step.step.dependOn(&install_map.step);
    b.getInstallStep().dependOn(&mod_tool_step.step);
}
