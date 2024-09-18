## Cmdfix

Allow user-defined commands to be typed lowercase in command line mode.

### Configuration

```lua
require("cmdfix").setup({
    enabled = true,  -- enable or disable plugin
    threshold = 2, -- minimum characters to consider before fixing the command
    ignore = { "CommandToIgnore" },  -- won't be fixed
    aliases = { VeryLongCommand = "vlc" },  -- custom aliases
})
```

### Notes

- Command expansion happens at the command line, just before a command is being executed or when pressing space after the command.
- You won't be able to use lowercase user-defined commands outside the command line.
- `:cabbrev` can be used for defining abbreviations in command line mode. However, they are rather impratical as the expansion can be triggered anywhere in the command line.
