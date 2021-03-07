# BlackQuartz Compositor

### Description:
Previus version was closed source and written Zig with Vulkan backend and planed as Quartz-like (macOS Compositor) with tiling (Yabai-like) transformation mode.
Actual version is planned as quite different thing. 

My goal is monolithic compositor with declaratative lua config in style of ![AwesomeWM](https://github.com/awesomeWM/awesome) from X11.


### Planned features:
- [ ] Simple configuration in Lua
- [ ] XWayland support (X11 apps)
- [ ] Support for gif wallpapers from ![oguri](https://github.com/vilhalmer/oguri)
- [ ] Say no to tiling (use sway or river)
- [ ] Support for GLSL Shaders as wallpaper
- [ ] Layershell support (mako, waybar and eww)
- [ ] Compositing effects such as animations, fading, flash focus and shadows


## FAQ:
**Q**: "Why C over Zig?"

**A**: "I really like Zig but it's not stable enough at least for me (update can break compositor) it's also a lot easier to embed Lua in C than Zig"


**Q2**: "Supported systems?"

**A2**: "I think my compositor should work on **NetBSD** and **FreeBSD** since both provide Wayland and wlroots support but I'm targetting **GNU/Linux** users"


**Q3**: "Another try to clone AwesomeWM on Wayland?"

**A3**: "No, I don't want to clone Awesome but just some features like mouse menu, prompts and declarative configuration"
