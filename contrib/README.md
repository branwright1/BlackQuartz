# Place for user made themes, scripts and clients
### Want to share your theme, script or link to your custom client? send Pull Request with docs/links etc.

**NOTE**: For clients creators, if you want to create custom client for e.g. tiling, include lua lib as config option.

### Example configuration for tiling client

```lua
-- tiling.lua

rqtile = rewuire("rqtile")

rqtile.options = {
    tiling.manual = false
    tiling.dynamic = true
    titlebar.disable = true
}

rqtile.layouts = {
    rqtile.tag.get = {
        name = "coding"
        gaps = 14
        layout = "vertical" 
    },
    rqtile.tag.get = {
        name = "chat"
        gaps = 10
        layout = "grid" 
    },
    rqtile.tag.get = {
        name = "music"
        gaps = 0
        layout = "floating"
    }
}

```