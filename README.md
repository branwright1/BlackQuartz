<h1 align="center">snowflake</h1>
<p align="center"><i>A programmatic floating wayland compositor</i></p>
<hr><p align="center">
<img alt="GitHub contributors" src="https://img.shields.io/github/contributors/HeavyRain266/SnowFlake">
<img alt="GitHub issues" src="https://img.shields.io/github/issues-raw/HeavyRain266/Snowflake?label=issues">
<img alt="GitHub license" src="https://img.shields.io/github/license/HeavyRain266/Snowflake">
</p>
<br></br>

## About this project

**Snowflake** is work in progress Wayland Compositor with [Programmatic Floating](https://github.com/tam-carre/dotfiles#programmatic-floating) layout. 

**What is it "Programmatic Floating" layout?** It's new take on "floating" layout, by default all clients in Snowflake are floating like in OpenBox for example. User can specify geometry, position and workspace as keybind for desired clients to create layouts, all those clients are sticked to configured parameters but you can just move them and still have as just floating until you hit keybind to get them back to predefined position. People can say that "tiling is more efficient" but I would say it's not thruth because you still have to position and resize windows by hands.

See [this gif](https://raw.githubusercontent.com/alnj/dotfiles/master/workflow.gif) from OpenBox as reference (thanks to [alnj](https://github.com/alnj)):

**About development stages**:
- Stage 0: server, compositor & damage tracking
- Stage 1: input/output config & clipboard
- Stage 2: flakes, decorations & xwayland
- Stage 3: custom protocols & animations

### Dependencies

- zig 0.8
- wayland
- wayland-protocols
- wlroots 0.14.0
- pkg-config
- libudev
- libevdev
- pixman
- libGL
- libxkbcommon
  <br></br>

## Build and test

```sh
# Clone repository with submodules.
git clone https://github.com/HeavyRain266/snowflake.git
cd snowflake; git submodule update --init

# Build compositor.
cd snowflake 
zig build -Drelease-safe

# Run Snowflake under X11 or Wayland session.
./zig-out/bin/snowflake

# Test nested under X11 session using any compatible client.
WAYLAND_DISPLAY=wayland-1 alacritty

# Test nested under Wayland session using any client
WAYLAND_DISPLAY=wayland-2 alacritty
```

## Special thanks

I really want say thanks to [sway](https://github.com/swaywm/sway) maintainers for [wlroots](https://github.com/swaywm/wlroots) which is excelent library for writting wayland compositors and clients, without wlroots development of Snowflake wouldn't be that easy. Thanks to [river](https://github.com/ifreund/river) maintainer which created [zig-wlroots](https://github.com/swaywm/zig-wlroots) bindings which gave me motivation to finally write my own compositor and [tinywl](https://github.com/swaywm/zig-wlroots/blob/master/tinywl) which was used as base for this project. All of them are spending a lot of time to make Wayland bbetter and better every day, it's hard to describe how much important it is to me, again really thanks you all for those excelent projects.

# License
Snowflake is released under [BSD 3-Clause License](https://github.com/HeavyRain266/snowflake/blob/master/LICENSE).

