<p align="center">
    <h2 align="center">RoseQuartz Compositor</h2>
</p>

<p align="center">
    <h4 align="center">Manual tiling through frames inspired by Herbstluftwm<h4>
</p>


### How does manual tiling works?
In manual tiling user decide where window should be spawned, in this case `framectl split left|right|top|bottom <size>` will create empty frame for you, this frame can handle single or multiple windows with optional gaps between them.

For example in [Herbstluftwm](https://github.com/herbstluftwm/herbstluftwm) every frame can can be controled by `herbstclient split <direction> <size>`, `herbstclient focus <direction>` and removed by `herbstclient remove`. 

Custom layouts can be created with `herbstclient chain . <command> . <another one> . <again> ...`.

### Deisgn goals
- RoseQuartz IPC (rosectl)
- Manual tiling protocol (framectl)
- Simple decorations (likw titlebars)
- GLSL Shaders as wallpaper or shadows
- Rename from BlackQuartz to RoseQuartz
- Complete rewrite from closed source version
