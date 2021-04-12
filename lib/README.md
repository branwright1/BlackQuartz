# Example for upcomming lua library
### Ouput handling (monitors, tags)

```lua
-- config.lua
-- load modules here
require("output.lua")
require("input.lua")
require("atrributes.lua")
```

```lua
-- output.lua or monitor.lua
-- this file handles output and defined "tags"
local rqctl = require("rosequartz")

-- Output handling
rqctl.monitor( "HDMI-A-1", {
    position = "0x0"
    mode = "1920x1080@74.973000Hz"
    adaptive_sync = "on"
})

-- Disable selected output
rqctl.monitor( "eDPI-1", {
    disable = true
})

-- define tables of tags
rqctl.tags_table = {
    rqctl.tag.add = {
        name = "chat"
        default = false
        monitor = "HDMI-A-1"
    },
    rqctl.tag.add = {
        name = "coding"
        -- selected on startup
        default = true
        monitor = "HDMI-A-1" 
    },
    rqctl.tag.add = {
        name = "music"
        default = false
        monitor = "HDMI-A-1"
    } 
}


```

### Input handling (keyboard, keybinds, touchpad, tablet)

```lua
local rqctl = require("rosequartz")

-- keyboard layout
rqctl.input({
    xkb_layout = "ie"
})

-- modifiers
rqctl.modkey = "Mod1"
rqctl.shift = "Shift"

-- example keybinds table
rqctl.keybind_table = {
    rqctl.key {
        modifiers = { }
        key = "Print"
        action = rqctl.shell("grimshot --notify copy")
    },
    rqctl.key {
        modifiers = { shift }
        key = "Print"
        action = rqctl.shell("grimshot --notify save")
    },
    rqctl.key {
        modifiers = { modkey }
        key = "Return"
        action = rqctl.spawn("alacritty")
    }
}
```

### Theme setttings (wallpaper, decorations)

```lua
-- attributes.lua 
local attr = require("rosequartz")

-- background settings
attr.backgorund = {
    image = "/path/to/image"
    solid = "#rrggbb"
    adjust = "scale|center|scratch"
}

-- control double borders
attr.border_inner_color = "#rrggbb"
attr.border_outer_color = "#rrggbb"
attr.border_inner_size = int
attr.border_outer_size = int

-- control titlebars
attr.titlebar_fg = "#rrggbb"
attr.titlebar_bg = "#rrggbb"
atrr.titlebar_size = int
attr.titlebar_font = "font_name <size>"
```