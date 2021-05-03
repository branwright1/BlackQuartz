<h1 align="center">RoseQuartz</h1>
<p align="center"><i>Small in design stacking Wayland Compositor with double borders</i></p>
<hr><p align="center">
</p>
<br></br>

## Special thanks:

[Wlroots](https://github.com/swaywm/wlroots) for excelent library which makes development way easier. Also thank to [river](https://github.com/ifreund/river) creator which made [zig-wlroots](https://github.com/swaywm/zig-wlroots) bindings which gave me motivation and [tinywl.zig](https://github.com/swaywm/zig-wlroots/blob/master/tinywl/tinywl.zig) used as base for this project.
<br></br>

## About project:

RoseQuartz is Small and user-friendly Wayland Compositor with double borders like in [2bwm](https://github.com/venam/2bwm).
<br></br>

## Building:

### Install following dependencies

- zig 0.7.1
- wayland
- wayland-protocols
- wlroots 0.13.0
- pkgconfig
- libudev
- libevdev
- pixman
- libGL
- libX11
- libxkbcommon
- direnv (optional)
  <br></br>

### Build and test:

```sh
# Create libc-paths file (fix bug on glibc-2.33+)
zig libc > libc-paths

# Build and run with X11 or Wayland backend
zig build run & disown

# Open compatible program
WAYLAND_DISPLAY=wayland-1 alacritty
```

### Extra steps for Nix/NixOS users:

```sh
# Ff you are using direnv
direnv allow .

# Standard nix users
nix-shell

# Experimental flake
nix develop
```
