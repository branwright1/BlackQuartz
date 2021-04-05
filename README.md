<p align="center">
    <h1 align="center">RoseQuartz Compositor</h1>
    <h3 align="center">Manual tiling through frames inspired by Herbstluftwm</h3>
</p>

### How does manual tiling works?
In manual tiling user decide where window should be spawned, in this case `rosectl split <direction> <size>` will create empty frame for you, this frame can handle single or multiple windows with optional gaps between them.

For example in [Herbstluftwm](https://github.com/herbstluftwm/herbstluftwm) every frame can can be controled by `herbstclient split <direction> <size>`, `herbstclient focus <direction>` and removed by `herbstclient remove`. Custom layouts can be created with `herbstclient chain . <command> . <another one> . <again> ...`.

### Why IPC instead of regular config file?
I don't want to limit my users to well known and widely used config files with hardcoded variables and functions, mostly because it's limiting functions of compositor and bothering with reloading/restarting when IPC allow you to change every possible variables on the fly and doesn't limit you to shell/yml/conf/ini etc. but let you use whatever you want for example: kotlin, golang, lua, lisp. I'm planning to separate tiling and decorations as protocols where people can create own clients connected to server which will allow you for generating layouts, creating theme collections or alternative IPC clients.

## Planed features:
### TIER 1: (Basic functionalities)
- [ ] Basic compositor 
- [ ] XWayland
- [ ] XDG Shell
- [ ] Layershell
- [ ] Screen copy
- [ ] Multi monitor

### TIER 2: (Usable state)
- [ ] RoseQuartz IPC
- [ ] Clipboard support
- [ ] Custom tiling layout
- [ ] Algorithm for frames
- [ ] Window animations
- [ ] GLSL shaders as window shadows

### TIER 3: (Abstractions)
- Possible Vulkan renderer
- Possible rewrite in Kotlin-native (llvm backend)
- Possible Support for NetBSD and FreeBSD (custom input and output protocols)


## Suported operating systems:
### TIER 1:
- [ ] Compatible with **ALL** Linux Distributions.

### TIER 2: (Requires custom protocols for e.g input)
- [ ] NetBSD
- [ ] FreeBSD
