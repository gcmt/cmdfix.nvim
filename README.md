## Cmdfix

Allow user-defined commands to be typed lowercase in command line mode. Also fixes typing mistakes such as `:W` and `:Set`, which are respectively fixed to `:w` and `:set` (but only if `W` and `Set` are not already user-defined commands)

### Installation

Your favorite plugin manager should work just fine.

### Configuration

```lua
require("cmdfix").setup({
    enabled = true,  -- enable or disable plugin
    threshold = 2, -- minimum characters to consider before fixing the command
    ignore = { "Next" },  -- won't be fixed (default value)
    aliases = { VeryLongCommand = "vlc" },  -- custom aliases
})
```

### Commands shadowing

If you have for example a user-defined command `:Marks`, the vim-native command `:marks` will effectively never be executed. If you want to retain the ability to execute both commands independently, just add the `Marks` command to the ignore list.

### Fixing rules

1. A command is fixed just before execution or after pressing space after the command (this allows command completion to still work for every command).
2. A lowercase command is fixed if a matching user-defined command is found and it's not ignored.
3. An uppercase command (a command containing an uppercase letter) is transformed to lowercase if a matching user-defined commadn IS NOT found and it's not ignored. The `threshold` option is ignored in this case.

### Notes

- Command expansion happens at the command line, just before a command is being executed or when pressing space after the command.
- You won't be able to use lowercase user-defined commands outside the command line.
- The native `:cabbrev` command can be used for defining abbreviations in command line mode. However, they are rather impratical as the expansion can be triggered anywhere in the command line.
