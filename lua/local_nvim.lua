local Path = require("plenary.path")
local Job = require("plenary.job")

local local_nvim = {}

local root = Path:new(vim.fn.stdpath("data"), "local.nvim")

local function _check_and_create(path)
    path = vim.fs.normalize(path)
    local p = Path:new(path)
    if not p:exists() then
        vim.api.nvim_err_writeln(path .. " does not exist!")
        return nil
    end
    return p
end

local function _md5sum(path)
    local j = Job:new({
        command = local_nvim.opts.command,
        args = { path },
    })
    local sum = j:sync()[1]
    return sum
end

function local_nvim.add(path)
    local p = _check_and_create(path)
    if not p then return end
    local sum = _md5sum(p:expand())
    if not root:exists() then
        root:mkdir({ parents = true })
    end
    local store_name = string.gsub(p:expand(), "/", "%%2F")
    Path:new(root, store_name):write(sum, 'w')
    if local_nvim.verbose then
        print(path, "added with sum", sum, "\nsourcing", path)
    end
    vim.api.nvim_exec(":source " .. path, nil)
end

function local_nvim.source(path)
    local p = _check_and_create(path)
    if not p then return end
    local store_name = string.gsub(p:expand(), "/", "%%2F")
    local sum_file = Path:new(root, store_name)
    if not sum_file:exists() then
        print(path, "was never added, use :LocalAdd")
        return
    end
    local current_sum = _md5sum(p:expand())
    local expected_sum = sum_file:read()
    if current_sum ~= expected_sum then
        print(path, "seems to have changed since last add, use :LocalAdd again to update")
        print(current_sum)
        print(expected_sum)
        return
    end
    if local_nvim.verbose then
        print(path, "found with correct sum", current_sum, "\nsourcing", path)
    end
    vim.api.nvim_exec(":source " .. path, nil)
    local_nvim.sourced_file = vim.fs.basename(path)
end

function local_nvim.find_and_source()
    for _, name in pairs(local_nvim.opts.filenames) do
        local p = Path:new(vim.loop.fs_realpath("."), name)
        if p:exists() then
            local_nvim.source(p.filename)
            break
        end
    end
end

function local_nvim.clean()
    root:rmdir()
    print("Cleaned!")
end

function local_nvim.setup(opts)
    opts = opts or {}
    if opts.autoload == nil then opts.autoload = true end
    local_nvim.opts = {
        command = opts.command or "md5sum",
        filenames = opts.filenames or { "nvim.lua", ".nvim.lua", ".nvimrc", ".vimrc", ".exrc" },
        autoload = opts.autoload,
        verbose = opts.verbose or false,
    }
    if opts.autoload then
        local id = vim.api.nvim_create_augroup("LocalNvim", {})
        vim.api.nvim_create_autocmd("VimEnter", {
            group = id,
            desc = "Find and source local nvim configuration file",
            callback = local_nvim.find_and_source,
        })
    end
end

if local_nvim.opts == nil then
    local_nvim.setup() -- auto setup
end

return local_nvim
