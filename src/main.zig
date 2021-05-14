const std = @import("std");
const os = std.os;
const hca = std.heap.c_allocator;

const wlr = @import("wlroots");
const xkb = @import("xkbommon");
const wl = @import("wayland").server.wl;

const Server = @import("base/Server.zig");

pub fn main() anyerror!void {
    wlr.log.init(.debug);

    var server: Server = undefined;
    try server.init();
    defer server.deinit();

    var buf: [11]u8 = undefined;
    const socket = try server.wl_server.addSocketAuto(&buf);

    if (os.argv.len >= 2) {
        const cmd = std.mem.span(os.argv[1]);
        var child = try std.ChildProcess.init(&[_][]const u8{ "/bin/sh", "-c", cmd }, hca);
        defer child.deinit();
        var env_map = try std.process.getEnvMap(hca);
        defer env_map.deinit();
        try env_map.set("WAYLAND_DISPLAY", socket);
        child.env_map = &env_map;
        try child.spawn();
    }

    try server.backend.start();

    std.log.info("Running RoseQuartz on WAYLAND_DISPLAY={}", .{socket});
    server.wl_server.run();
}