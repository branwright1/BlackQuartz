const std = @import("std");
const Builder = std.build.Builder;
const Pkg = std.build.Pkg;

const ScanProtocolsStep = @import("libs/zig-wayland/build.zig").ScanProtocolsStep;

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const scanner = ScanProtocolsStep.create(b);
    scanner.addSystemProtocol("stable/xdg-shell/xdg-shell.xml");

    const wayland = scanner.getPkg();
    const xkbcommon = Pkg{ .name = "xkbcommon", .path = "libs/zig-xkbcommon/src/xkbcommon.zig" };
    const pixman = Pkg{ .name = "pixman", .path = "libs/zig-pixman/pixman.zig" };
    const wlroots = Pkg{
        .name = "wlroots",
        .path = "libs/zig-wlroots/src/wlroots.zig",
        .dependencies = &[_]Pkg{ wayland, xkbcommon, pixman },
    };

    const snowflake = b.addExecutable("snowflake", "src/main.zig");
    snowflake.setTarget(target);
    snowflake.setBuildMode(mode);

    snowflake.linkLibC();

    snowflake.addPackage(wayland);
    snowflake.linkSystemLibrary("wayland-server");
    snowflake.step.dependOn(&scanner.step);
    // TODO: remove when https://github.com/ziglang/zig/issues/131 is implemented
    scanner.addCSource(snowflake);

    snowflake.addPackage(xkbcommon);
    snowflake.linkSystemLibrary("xkbcommon");

    snowflake.addPackage(wlroots);
    snowflake.linkSystemLibrary("wlroots");
    snowflake.linkSystemLibrary("pixman-1");

    snowflake.install();

    const run_cmd = snowflake.run();
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the compositor");
    run_step.dependOn(&run_cmd.step);
}
