const Output = @This();

const std = @import("std");
const os = std.os;

const wlr = @import("wlroots");
const wl = @import("wayland").server.wl;

const Server = @import("Server.zig");
const View = @import("View.zig");

const RenderData = struct {
    wlr_output: *wlr.Output,
    view: *View,
    renderer: *wlr.Renderer,
    when: *os.timespec,
};

server: *Server,
wlr_output: *wlr.Output,

frame: wl.Listener(*wlr.Output) = wl.Listener(*wlr.Output).init(frame),

pub fn frame(listener: *wl.Listener(*wlr.Output), wlr_output: *wlr.Output) void {
    const output = @fieldParentPtr(Output, "frame", listener);
    const server = output.server;

    var now: os.timespec = undefined;
    os.clock_gettime(os.CLOCK_MONOTONIC, &now) catch @panic("CLOCK_MONOTONIC not supported");

    wlr_output.attachRender(null) catch return;

    server.renderer.begin(@intCast(u32, wlr_output.width), @intCast(u32, wlr_output.height));

    const color = [4]f32{ 0.9, 0.9, 0.8, 1.0 };
    server.renderer.clear(&color);

    var it = server.views.iterator(.reverse);
    while (it.next()) |view| {
        var rdata = RenderData{
            .wlr_output = wlr_output,
            .view = view,
            .renderer = server.renderer,
            .when = &now,
        };
        view.xdg_surface.forEachSurface(*RenderData, renderSurface, &rdata);
    }

    wlr_output.renderSoftwareCursors(null);

    server.renderer.end();

    // rollback changes on failure
    wlr_output.commit() catch {};
}

fn renderSurface(surface: *wlr.Surface, sx: c_int, sy: c_int, rdata: *RenderData) callconv(.C) void {
    const wlr_output = rdata.wlr_output;
    const texture = surface.getTexture() orelse return;

    var ox: f64 = 0;
    var oy: f64 = 0;
    rdata.view.server.output_layout.outputCoords(wlr_output, &ox, &oy);
    ox += @intToFloat(f64, rdata.view.x + sx);
    oy += @intToFloat(f64, rdata.view.y + sy);

    var box = wlr.Box{
        .x = @floatToInt(c_int, ox * wlr_output.scale),
        .y = @floatToInt(c_int, oy * wlr_output.scale),
        .width = @floatToInt(c_int, @intToFloat(f32, surface.current.width) * wlr_output.scale),
        .height = @floatToInt(c_int, @intToFloat(f32, surface.current.height) * wlr_output.scale),
    };

    var matrix: [9]f32 = undefined;
    const transform = wlr.Output.transformInvert(surface.current.transform);
    wlr.matrix.projectBox(&matrix, &box, transform, 0, &wlr_output.transform_matrix);

    // let wlroots handle errors
    rdata.renderer.renderTextureWithMatrix(texture, &matrix, 1) catch {};
    surface.sendFrameDone(rdata.when);
}
