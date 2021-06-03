<h1 align="center">RoseQuartz</h1>
<p align="center"><i>A programmatic floating wayland compositor</i></p>
<hr><p align="center">
<img alt="GitHub contributors" src="https://img.shields.io/github/contributors/HeavyRain266/RoseQuartz?label=Contributors">
<img alt="GitHub issues" src="https://img.shields.io/github/issues/HeavyRain266/RoseQuartz">
<img alt="GitHub" src="https://img.shields.io/github/license/HeavyRain266/RoseQuartz">
</p>
<br></br>

## Special thanks:

[wlroots](https://github.com/swaywm/wlroots) for excelent library which makes development way easier. Also thank to [river](https://github.com/ifreund/river) creator which made [zig-wlroots](https://github.com/swaywm/zig-wlroots) bindings which gave me motivation and [tinywl.zig](https://github.com/swaywm/zig-wlroots/blob/master/tinywl/tinywl.zig) used as base for this project.
<br></br>

## About project:

**RoseQuartz** is work in progress Wayland Compositor with [Programmatic Floating](https://github.com/alnj/dotfiles) layout. That means user define position and geometry for selected apps and windows to create layout per workspace.

See [this gif](https://raw.githubusercontent.com/alnj/dotfiles/master/workflow.gif) from OpenBox as reference (thanks to [alnj](https://github.com/alnj)):

### List of things which I want to implement before switch from [river](https://github.com/ifreund/river):
- IPC: roseclient
- Clipboard: probably hardest part
- Lua wrapper: roseclient as lua library for config
- XWayland: for Android Studio and Autodesk Maya
- Graphics tablet: for Autodesk Maya
- Double borders: stolen idea from [2bwm](https://github.com/venam/2bwm)
- Damage tracking: for low battery usage on laptop
- Kotlin rewrite: once my [kt-wlroots](https://github.com/HeavyRain266/kt-wlroots) will be finished
<br></br>

## Dependencies:

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

## Building and testing:

```sh
# Create libc-paths file (fix bug on glibc-2.33+)
zig libc > libc-paths
# Build and run with X11 or Wayland backend
zig build run & disown
# Open compatible program
WAYLAND_DISPLAY=wayland-1 alacritty
```
