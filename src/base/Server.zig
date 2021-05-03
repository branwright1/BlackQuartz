const Server = @This();

const std = @import("std");
const os = std.os;
const hca = std.heap.c_allocator;

const wlr = @import("wlroots");
const xkb = @import("xkbcommon");
const wl = @import("wayland").server.wl;

const Output = @import("Output.zig");
const View = @import("View.zig");
const Cursor = @import("../input/Cursor.zig");
const Keyboard = @import("../input/Keyboard.zig");

wl_server: *wl.Server,
backend: *wlr.Backend,
renderer: *wlr.Renderer,

output_layout: *wlr.OutputLayout,
new_output: wl.Listener(*wlr.Output) = wl.Listener(*wlr.Output).init(newOutput),

xdg_shell: *wlr.XdgShell,
new_xdg_surface: wl.Listener(*wlr.XdgSurface) = wl.Listener(*wlr.XdgSurface).init(newXdgSurface),
views: wl.list.Head(View, "link") = undefined,

seat: *wlr.Seat,
new_input: wl.Listener(*wlr.InputDevice) = wl.Listener(*wlr.InputDevice).init(newInput),
request_set_cursor: wl.Listener(*wlr.Seat.event.RequestSetCursor) = wl.Listener(*wlr.Seat.event.RequestSetCursor).init(requestSetCursor),
request_set_selection: wl.Listener(*wlr.Seat.event.RequestSetSelection) = wl.Listener(*wlr.Seat.event.RequestSetSelection).init(requestSetSelection),
keyboards: wl.list.Head(Keyboard, "link") = undefined,

cursor: *Cursor,
cursor_mgr: *wlr.XcursorManager,

pub fn init(server: *Server) !void {
    const wl_server = try wl.Server.create();
    const backend = try wlr.Backend.autocreate(wl_server);
    server.* = .{
        .wl_server = wl_server,
        .backend = backend,
        .renderer = backend.getRenderer() orelse return error.GetRendererFailed,
        .output_layout = try wlr.OutputLayout.create(),
        .xdg_shell = try wlr.XdgShell.create(wl_server),
        .seat = try wlr.Seat.create(wl_server, "default"),
        .cursor = try wlr.Cursor.create(),
        .cursor_mgr = try wlr.XcursorManager.create(null, 24),
    };

    try server.renderer.initServer(wl_server);

    _ = try wlr.Compositor.create(server.wl_server, server.renderer);
    _ = try wlr.DataDeviceManager.create(server.wl_server);

    server.backend.events.new_output.add(&server.new_output);

    server.xdg_shell.events.new_surface.add(&server.new_xdg_surface);
    server.views.init();

    server.backend.events.new_input.add(&server.new_input);
    server.seat.events.request_set_cursor.add(&server.request_set_cursor);
    server.seat.events.request_set_selection.add(&server.request_set_selection);
    server.keyboards.init();

    server.cursor.attachOutputLayout(server.output_layout);
    try server.cursor_mgr.load(1);
    cursor.events.motion.add(&cursor.motion);
    cursor.events.motion_absolute.add(&curosr.motion_absolute);
    cursor.events.button.add(&cursor.button);
    cursor.events.axis.add(&cursor.button);
    cursor.events.frame.add(&cursor.frame);
}

pub fn deinit(server: *Server) void {
    server.wl_server.destroyClients();
    server.wl_server.destroy();
}

fn newOutput(listener: *wl.Listener(*wlr.Output), wlr_output: *wlr.Output) void {
    const server = @fieldParentPtr(Server, "new_output", listener);

    if (wlr_output.preferredMode()) |mode| {
        wlr_output.setMode(mode);
        wlr_output.enable(true);
        wlr_output.commit() catch return;
    }

    const output = hca.create(Output) catch {
        std.log.crit("Unable to allocate new output", .{});
        return;
    };

    output.* = .{
        .server = server,
        .wlr_output = wlr_output,
    };

    wlr_output.events.frame.add(&output.frame);

    server.output_layout.addAuto(wlr_output);
}

fn newXdgSurface(listener: *wl.Listener(*wlr.XdgSurface), xdg_surface: *wlr.XdgSurface) void {
    const server = @fieldParentPtr(Server, "new_xdg_surface", listener);

    if (xdg_surface.role != .toplevel) return;

    const view = hca.create(View) catch {
        std.log.crit("Unable to allocate new view", .{});
        return;
    };

    view.* = .{
        .server = server,
        .xdg_surface = xdg_surface,
        .cursor = cursor,
    };

    xdg_surface.events.map.add(&view.map);
    xdg_surface.events.unmap.add(&view.unmap);
    xdg_surface.events.destroy.add(&view.destroy);
    xdg_surface.role_data.toplevel.events.request_move.add(&view.request_move);
    xdg_surface.role_data.toplevel.events.request_resize.add(&view.request_resize);
}

const ViewAtResult = struct {
    view: *View,
    surface: *wlr.Surface,
    sx: f64,
    sy: f64,
};

fn viewAt(server: *Server, lx: f64, ly: f64) ?ViewAtResult {
    var it = server.views.iterator(.forward);
    while (it.next()) |view| {
        var sx: f64 = undefined;
        var sy: f64 = undefined;
        const x = lx - @intToFloat(f64, view.x);
        const y = ly - @intToFloat(f64, view.y);
        if (view.xdg_surface.surfaceAt(x, y, &sx, &sy)) |surface| {
            return ViewAtResult{
                .view = view,
                .surface = surface,
                .sx = sx,
                .sy = sy,
            };
        }
    }
    return null;
}

pub fn focusView(server: *Server, view: *View, surface: *wlr.Surface) void {
    if (server.seat.keyboard_state.focused_surface) |previous_surface| {
        if (previous_surface == surface) return;
        if (previous_surface.isXdgSurface()) {
            const xdg_surface = wlr.XdgSurface.fromWlrSurface(previous_surface);
            _ = xdg_surface.role_data.toplevel.setActivated(false);
        }
    }

    view.link.remove();
    server.views.prepend(view);

    _ = view.xdg_surface.role_data.toplevel.setActivated(true);

    const wlr_keyboard = server.seat.getKeyboard() orelse return;
    server.seat.keyboardNotifyEnter(
        surface,
        &wlr_keyboard.keycodes,
        wlr_keyboard.num_keycodes,
        &wlr_keyboard.modifiers,
    );
}

fn newInput(listener: *wl.Listener(*wlr.InputDevice), device: *wlr.InputDevice) void {
    const server = @fieldParentPtr(Server, "new_input", listener);
    switch (device.type) {
        .keyboard => Keyboard.create(server, device) catch |err| {
            std.log.err("Unable to create keyboard: {}", .{err});
            return;
        },
        .pointer => wlr.Cursor.attachInputDevice(device),
        else => {},
    }

    server.seat.setCapabilities(.{
        .pointer = true,
        .keyboard = server.keyboards.length() > 0,
    });
}

fn requestSetCursor(
    listener: *wl.Listener(*wlr.Seat.event.RequestSetCursor),
    event: *wlr.Seat.event.RequestSetCursor,
) void {
    const server = @fieldParentPtr(Server, "request_set_cursor", listener);
    if (event.seat_client == server.seat.pointer_state.focused_client)
        server.setSurface(event.surface, event.hotspot_x, event.hotspot_y);
}

fn requestSetSelection(
    listener: *wl.Listener(*wlr.Seat.event.RequestSetSelection),
    event: *wlr.Seat.event.RequestSetSelection,
) void {
    const server = @fieldParentPtr(Server, "request_set_selection", listener);
    server.seat.setSelection(event.source, event.serial);
}

pub fn handleKeybind(server: *Server, key: xkb.Keysym) bool {
    switch (key) {
        .Delete => server.wl_server.terminate(),
        .Left => {
            if (server.views.length() < 2) return true;
            const view = @fieldParentPtr(View, "link", server.views.link.prev.?);
            server.focusView(view, view.xdg_surface.surface);
        },
        else => return false,
    }
    return true;
}
