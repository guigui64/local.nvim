local Path = require("plenary.path")
local Job = require("plenary.job")

local M = {}

local root = Path:new(vim.fn.stdpath("data"), "local.nvim")

function M.setup(opts)
    opts = opts or {}
    M.opts = {
        command = opts.command or "md5sum",
        filenames = { "nvim.lua", ".nvim.lua", ".nvimrc", ".vimrc" },
    }
end

if M.opts == nil then
    M.setup() -- auto setup
end

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
        command = M.opts.command,
        args = { path },
    })
    local sum = j:sync()[1]
    return string.sub(sum, 0, string.find(sum, " ") - 1)
end

function M.local_add(path)
    local p = _check_and_create(path)
    if not p then return end
    local sum = _md5sum(path)
    if not root:exists() then
        root:mkdir({ parents = true })
    end
    local store_name = string.gsub(p:expand(), "/", "%%2F")
    Path:new(root, store_name):write(sum, 'w')
    print(path, "added with sum", sum, "\nsourcing", path)
    vim.api.nvim_exec(":source " .. path, nil)
end

function M.local_source(path)
    local p = _check_and_create(path)
    if not p then return end
    local store_name = string.gsub(p:expand(), "/", "%%2F")
    local sum_file = Path:new(root, store_name)
    if not sum_file:exists() then
        print(path, "was never added, use :LocalAdd")
        return
    end
    local current_sum = _md5sum(path)
    local expected_sum = sum_file:read()
    if current_sum ~= expected_sum then
        print(path, "seems to have changed since last add, use :LocalAdd again to update")
        return
    end
    print(path, "found with correct sum", current_sum, "\nsourcing", path)
    vim.api.nvim_exec(":source " .. path, nil)
end

local function test()
    -- M.local_add("/foo/bar.txt")
    M.local_add("/tmp/test.lua")
    M.local_source("/tmp/test.lua")
end

test()

return M
