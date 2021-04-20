<p align="center">
    <h1 align="center">RoseQuartz Compositor</h1>
    <h4 align="center">Small in design stacking Wayland Compositor with double borders</h4>
</p>

## Dependencies
**NOTE**: some packages can have different names and version depending on your distribution.

zig 0.7.1
wlroots 0.13.0
wayland
wayland-protocols
pkgconfig
libudev
libevdev
pixman
libGL
libX11
libxkbcommon

## Build and test
```sh
git clone https://github.com/branwright1/RoseQuartz.git --recurse-submodules

cd RoseQuartz
git submodule init

## for NixOS users:
nix-shell
## for nix-flakes users:
nix develop

## Build and test under X11/Wayland
zig build run & disown

# Open terminal
WAYLAND_DISPLAY=wayland-1 <foot|alacritty>
```

# Description
**NOTE:** Some parts described here might be changed in the feature.

**RoseQuartz** - Small in design stacking Wayland Compositor with double borders. Heavly inspired by tinywl.zig, river and 2bwm. Please note that Compositor is currently in really early stage of development and should be used only for testing purpose running under Wayland or X11 backend. Next few months will bring support for popular wlroots protocols, IPC client, custom protocols, double borders, possible titlebars, animations and GLSL Shaders used as shadows.
