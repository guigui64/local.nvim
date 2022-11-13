if vim.g.loaded_local_nvim == 1 then return end
vim.g.loaded_local_nvim = 1

local local_nvim = require("local_nvim")

-- user commands
vim.api.nvim_create_user_command("LocalAdd", function(opts) local_nvim.add(opts.args) end, {
    nargs = 1,
    complete = "file",
    desc = "Add or update a local configuration file"
})
vim.api.nvim_create_user_command("LocalSource", local_nvim.find_and_source, {
    desc = "Try to find and source a local configuration file"
})
vim.api.nvim_create_user_command("LocalClean", local_nvim.clean, {
    desc = "Remove all previously added configuration files"
})
