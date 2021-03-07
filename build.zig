const std = @import("std");
const Builder = std.build.Builder;
const Pkg = std.build.Pkg;

const ScanProtocolsStep = @import("lib/zig-wayland/build.zig").ScanProtocolsStep;

pub fn build(bld: *Builder) void {
    const target = bld.standardTargetOptions(.{});
    const mode = bld.standardReleaseOptions();

    const scanner = ScanProtocolsStep.create(bld);
    scanner.addSystemProtocol("stable/xdg-shell/xdg-shell.xml");

    const wayland = scanner.getPkg();
    const xkbcommon = Pkg{ .name = "xkbcommon", .path = "lib/zig-xkbcommon/src/xkbcommon.zig" };
    const pixman = Pkg{ .name = "pixman", .path = "lib/zig-pixman/pixman.zig" };
    const wlroots = Pkg{
        .name = "wlroots",
        .path = "lib/zig-wlroots/src/wlroots.zig",
        .dependencies = &[_]Pkg{ wayland, xkbcommon, pixman },
    };

    const exe = bld.addExecutable("rosequartz", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);

    exe.linkLibC();

    exe.addPackage(wayland);
    exe.linkSystemLibrary("wayland-server");
    exe.step.dependOn(&scanner.step);
    // TODO: remove when https://github.com/ziglang/zig/issues/131 is implemented
    //:wascanner.addCSource(exe);

    exe.addPackage(xkbcommon);
    exe.linkSystemLibrary("xkbcommon");

    exe.addPackage(wlroots);
    exe.linkSystemLibrary("wlroots");
    exe.linkSystemLibrary("pixman-1");

    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(bld.getInstallStep());

    const run_step = bld.step("run", "Run the compositor");
    run_step.dependOn(&run_cmd.step);
}
