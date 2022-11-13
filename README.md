# local.nvim

Neovim plugin for per-project local configuration files

## Why?

For security reasons, the `'exrc'` feature has been deprecated.

By storing hashes of the files, this plugin adds the needed security to automatically loaded pre-verified per-project local configuration files.

## Install

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use("nvim-lua/plenary.nvim") -- required dependency
use("guigui64/local.nvim")
```

## Usage

### Commands

The folowing commands are available:

* `:LocalAdd <file>`: add or update a configuration file. It will compute and store its hash and source it.
* `:LocalSource`: find and source a local configuration file.
* `:LocalClean`: remove all the previously added hashes.


### Configuration

To configure `local.nvim`, you can use the `setup()` method. The default values are shown below.
You can skip the whole `setup` call if you are happy with the defaults.

```lua
require("local_nvim").setup({
    command = "md5sum", -- executable to use for computing files hashes
    filenames = { "nvim.lua", ".nvim.lua", ".nvimrc", ".vimrc", ".exrc" }, -- looked for filenames (order matters)
    autoload = true, -- automatically find and source file with configured filenames on VimEnter
    verbose = false, -- add some debug messages
})
```

### Integrate with statusline

`require("local_nvim").sourced_file` will be set to the basename of the sourced file (or `nil` if there is none).

For example:

#### Lualine

```lua
require("lualine").setup({
    sections = {
        lualine_x = { function()
            local sf = require("local_nvim").sourced_file
            if sf then
                return "[" .. sf .. "]"
            end
            return ""
        end, "filetype" },
    }
})
```
