const View = @This();

const std = @import("std");
const os = std.os;
const hca = std.heap.c_allocator;

const wlr = @import("wlroots");
const wl = @import("wayland").server.wl;

const Server = @import("Server.zig");
const Cursor = @import("../input/Cursor.zig");

server: *Server,
cursor: *Cursor,
link: wl.list.Link = undefined,
xdg_surface: *wlr.XdgSurface,

x: i32 = 0,
y: i32 = 0,

map: wl.Listener(*wlr.XdgSurface) = wl.Listener(*wlr.XdgSurface).init(map),
unmap: wl.Listener(*wlr.XdgSurface) = wl.Listener(*wlr.XdgSurface).init(unmap),
destroy: wl.Listener(*wlr.XdgSurface) = wl.Listener(*wlr.XdgSurface).init(destroy),
request_move: wl.Listener(*wlr.XdgToplevel.event.Move) = wl.Listener(*wlr.XdgToplevel.event.Move).init(requestMove),
request_resize: wl.Listener(*wlr.XdgToplevel.event.Resize) = wl.Listener(*wlr.XdgToplevel.event.Resize).init(requestResize),

pub fn map(listener: *wl.Listener(*wlr.XdgSurface), xdg_surface: *wlr.XdgSurface) void {
    const view = @fieldParentPtr(View, "map", listener);
    view.server.views.prepend(view);
    view.x -= xdg_surface.geometry.x;
    view.y -= xdg_surface.geometry.y;
    view.server.focusView(view, xdg_surface.surface);
}

fn unmap(listener: *wl.Listener(*wlr.XdgSurface), xdg_surface: *wlr.XdgSurface) void {
    const view = @fieldParentPtr(View, "unmap", listener);
    view.link.remove();
}

fn destroy(listener: *wl.Listener(*wlr.XdgSurface), xdg_surface: *wlr.XdgSurface) void {
    const view = @fieldParentPtr(View, "destroy", listener);

    view.map.link.remove();
    view.unmap.link.remove();
    view.destroy.link.remove();
    view.request_move.link.remove();
    view.request_resize.link.remove();

    hca.destroy(view);
}

fn requestMove(
    listener: *wl.Listener(*wlr.XdgToplevel.event.Move),
    event: *wlr.XdgToplevel.event.Move,
) void {
    const view = @fieldParentPtr(View, "request_move", listener);
    const server = view.server;
    cursor.grabbed_view = view;
    cursor.mode = .move;
    cursor.grab_x = cursor.x - @intToFloat(f64, view.x);
    cursor.grab_y = cursor.y - @intToFloat(f64, view.y);
}

fn requestResize(
    listener: *wl.Listener(*wlr.XdgToplevel.event.Resize),
    event: *wlr.XdgToplevel.event.Resize,
) void {
    const view = @fieldParentPtr(View, "request_resize", listener);
    const server = view.server;

    cursor.grabbed_view = view;
    cursor.mode = .resize;
    cursor.resize_edges = event.edges;

    var box: wlr.Box = undefined;
    view.xdg_surface.getGeometry(&box);

    const border_x = view.x + box.x + if (event.edges.right) box.width else 0;
    const border_y = view.y + box.y + if (event.edges.bottom) box.height else 0;
    cursor.grab_x = cursor.x - @intToFloat(f64, border_x);
    cursor.grab_y = cursor.y - @intToFloat(f64, border_y);

    cursor.grab_box = box;
    cursor.grab_box.x += view.x;
    cursor.grab_box.y += view.y;
}
