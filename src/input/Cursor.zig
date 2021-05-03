const Cursor = @This();

const std = @import("std");
const wl = @import("wayland").server.wl;
const wlr = @import("wlroots");
const Server = @import("../base/Server.zig");
const View = @import("../base/View.zig");

server: *Server,
mgr: *wlr.XcursorManager,
button: wl.Listener(*wlr.Pointer.event.Button) = wl.Listener(*wlr.Pointer.event.Button).init(cursorButton),
axis: wl.Listener(*wlr.Pointer.event.Axis) = wl.Listener(*wlr.Pointer.event.Axis).init(cursorAxis),
frame: wl.Listener(*wlr.Cursor) = wl.Listener(*wlr.Cursor).init(cursorFrame),

mode: enum { passthrough, move, resize } = .passthrough,
grabbed_view: ?*View = null,
grab_x: f64 = 0,
grab_y: f64 = 0,
grab_box: wlr.Box = undefined,
resize_edges: wlr.Edges = .{},

pub fn cursorMotion(
    listener: *wl.Listener(*wlr.Pointer.event.Motion),
    event: *wlr.Pointer.event.Motion,
) void {
    const server = @fieldParentPtr(Server, "cursor_motion", listener);
    cursor.move(event.device, event.delta_x, event.delta_y);
    server.processCursorMotion(event.time_msec);
}

fn cursorMotionAbsolute(
    listener: *wl.Listener(*wlr.Pointer.event.MotionAbsolute),
    event: *wlr.Pointer.event.MotionAbsolute,
) void {
    const server = @fieldParentPtr(Server, "cursor_motion_absolute", listener);
    cursor.warpAbsolute(event.device, event.x, event.y);
    server.processCursorMotion(event.time_msec);
}

fn processCursorMotion(server: *Server, time_msec: u32) void {
    switch (mode) {
        .passthrough => if (server.viewAt(cursor.x, cursor.y)) |res| {
            server.seat.pointerNotifyEnter(res.surface, res.sx, res.sy);
            server.seat.pointerNotifyMotion(time_msec, res.sx, res.sy);
        } else {
            mgr.setCursorImage("left_ptr", cursor);
            server.seat.pointerClearFocus();
        },
        .move => {
            grabbed_view.?.x = @floatToInt(i32, cursor.x - server.grab_x);
            grabbed_view.?.y = @floatToInt(i32, cursor.y - server.grab_y);
        },
        .resize => {
            const view = grabbed_view.?;
            const border_x = @floatToInt(i32, cursor.x - server.grab_x);
            const border_y = @floatToInt(i32, cursor.y - server.grab_y);

            var new_left = grab_box.x;
            var new_right = grab_box.x + grab_box.width;
            var new_top = grab_box.y;
            var new_bottom = grab_box.y + grab_box.height;

            if (server.resize_edges.top) {
                new_top = border_y;
                if (new_top >= new_bottom)
                    new_top = new_bottom - 1;
            } else if (server.resize_edges.bottom) {
                new_bottom = border_y;
                if (new_bottom <= new_top)
                    new_bottom = new_top + 1;
            }

            if (server.resize_edges.left) {
                new_left = border_x;
                if (new_left >= new_right)
                    new_left = new_right - 1;
            } else if (server.resize_edges.right) {
                new_right = border_x;
                if (new_right <= new_left)
                    new_right = new_left + 1;
            }

            var geo_box: wlr.Box = undefined;
            view.xdg_surface.getGeometry(&geo_box);
            view.x = new_left - geo_box.x;
            view.y = new_top - geo_box.y;

            const new_width = @intCast(u32, new_right - new_left);
            const new_height = @intCast(u32, new_bottom - new_top);
            _ = view.xdg_surface.role_data.toplevel.setSize(new_width, new_height);
        },
    }
}

fn cursorButton(
    listener: *wl.Listener(*wlr.Pointer.event.Button),
    event: *wlr.Pointer.event.Button,
) void {
    const server = @fieldParentPtr(Server, "button", listener);
    _ = server.seat.pointerNotifyButton(event.time_msec, event.button, event.state);
    if (event.state == .released) {
        mode = .passthrough;
    } else if (server.viewAt(cursor.x, cursor.y)) |res| {
        server.focusView(res.view, res.surface);
    }
}

fn cursorAxis(
    listener: *wl.Listener(*wlr.Pointer.event.Axis),
    event: *wlr.Pointer.event.Axis,
) void {
    const server = @fieldParentPtr(Server, "axis", listener);
    server.seat.pointerNotifyAxis(
        event.time_msec,
        event.orientation,
        event.delta,
        event.delta_discrete,
        event.source,
    );
}

fn cursorFrame(listener: *wl.Listener(*wlr.Cursor), wlr_cursor: *wlr.Cursor) void {
    const server = @fieldParentPtr(Server, "frame", listener);
    server.seat.pointerNotifyFrame();
}