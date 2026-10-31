-- Tiny lazy-loading layer for vim.pack.
-- Each "module" is a lua/plugins/**/<feature>.lua file that calls vim.pack.add()
-- and .setup(). Nothing runs until a trigger fires; each module runs once.
-- vim.pack.add() works after startup too, adding plugins to the runtimepath
-- and sourcing their plugin/ files.
--
-- Triggers: event (M.event), idle (M.idle), cmd (M.cmd), module (M.module)
-- Debug: :lua =require('lazy_load').loaded()

local M = {}

local done = {} -- config module -> true
local stubs = {} -- config module -> { stub command names }
local by_module = {} -- top-level Lua module -> config module

local augroup = vim.api.nvim_create_augroup('lazy_load', { clear = true })

local function as_list(x) return type(x) == 'table' and x or { x } end

local function fail(what, err) vim.notify(('lazy_load: %s failed\n%s'):format(what, err), vim.log.levels.ERROR) end

local function load_all(mods)
  for _, mod in ipairs(as_list(mods)) do
    M.load(mod)
  end
end

---Load a config module, at most once.
---@param mod string
function M.load(mod)
  if done[mod] then return end
  done[mod] = true

  -- Delete stubs first to avoid "command already exists" errors.
  for _, name in ipairs(stubs[mod] or {}) do
    pcall(vim.api.nvim_del_user_command, name)
  end
  stubs[mod] = nil

  local ok, err = pcall(require, mod)
  if not ok then fail(mod, err) end
end

---Load module(s) the first time any of `events` fires.
---@param events string|string[]
---@param mods string|string[]
function M.event(events, mods)
  vim.api.nvim_create_autocmd(events, {
    group = augroup,
    once = true,
    callback = function() load_all(mods) end,
  })
end

---Load module(s) once startup is done (VimEnter-safe for scripts).
---@param mods string|string[]
function M.idle(mods)
  if vim.v.vim_did_enter == 1 then
    vim.schedule(function() load_all(mods) end)
    return
  end
  vim.api.nvim_create_autocmd('VimEnter', {
    group = augroup,
    once = true,
    callback = function()
      vim.schedule(function() load_all(mods) end)
    end,
  })
end

---Stub user commands to load `mod` on first use, then run the real command.
---@param names string|string[]
---@param mod string
function M.cmd(names, mod)
  if done[mod] then return end
  stubs[mod] = stubs[mod] or {}
  for _, name in ipairs(as_list(names)) do
    table.insert(stubs[mod], name)
    vim.api.nvim_create_user_command(name, function(args)
      M.load(mod)
      local ok, err = pcall(vim.api.nvim_cmd, {
        cmd = name,
        args = args.fargs,
        bang = args.bang,
      }, {})
      if not ok then fail(name, err) end
    end, { nargs = '*', bang = true, desc = 'lazy_load: ' .. mod })
  end
end

---Load `mod` the first time a top-level Lua module is required.
---@param map table<string, string>
function M.module(map)
  for name, mod in pairs(map) do
    by_module[name] = mod
  end
end

-- Searcher: loads config module when plugin isn't on runtimepath.
local loaders = package.loaders or package.searchers
local function searcher(name)
  local mod = by_module[name:match '^[^.]+']
  if not mod or done[mod] then return end

  M.load(mod)
  local cached = package.loaded[name]
  if cached ~= nil then
    return function() return cached end
  end

  for _, loader in ipairs(loaders) do
    if loader ~= searcher then
      local found = loader(name)
      if type(found) == 'function' then return found end
    end
  end
end
table.insert(loaders, searcher)

---Names of loaded config modules (debugging).
---@return string[]
function M.loaded()
  local names = vim.tbl_keys(done)
  table.sort(names)
  return names
end

return M
-- vim: ts=2 sts=2 sw=2 et
