-- Tiny lazy-loading layer for vim.pack.
--
-- A "module" here is one lua/plugins/**/<feature>.lua file: it calls
-- vim.pack.add() for its plugins and then .setup(). Nothing runs until a
-- trigger fires, and each module runs at most once.
--
-- vim.pack.add() keeps working after startup: it adds the plugin to the
-- runtimepath and sources its plugin/ files, so there is no custom load step.
--
-- Triggers:
--   event   first time one of the events fires            M.event
--   idle    once VimEnter has fired (after the first paint) M.idle
--   cmd     first use of a user command                   M.cmd
--   module  first require() of a module the plugin owns   M.module
--
-- Check what has loaded so far with:  :lua =require('lazy_load').loaded()

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

  -- Remove this module's command stubs first: if the plugin defines its real
  -- command while our stub still exists, Neovim raises "command already
  -- exists". This also covers loads that arrive through another trigger
  -- (idle, event, module searcher) before the stub was ever used.
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

---Load module(s) once startup is done.
---VimEnter fires in headless mode too, so this also works for scripts; the
---schedule puts it after the first paint in a real UI.
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

---Stub user commands so the first use loads `mod`, then runs the real command.
---@param names string|string[]
---@param mod string
function M.cmd(names, mod)
  if done[mod] then return end -- real commands already exist; don't shadow them
  stubs[mod] = stubs[mod] or {}
  for _, name in ipairs(as_list(names)) do
    table.insert(stubs[mod], name)
    vim.api.nvim_create_user_command(name, function(args)
      M.load(mod) -- deletes the stub, defines the real command
      local ok, err = pcall(vim.api.nvim_cmd, {
        cmd = name,
        args = args.fargs,
        bang = args.bang,
      }, {})
      if not ok then fail(name, err) end
    end, { nargs = '*', bang = true, desc = 'lazy_load: ' .. mod })
  end
end

---Load `mod` the first time one of its Lua modules is required before the
---plugin has been added to the runtimepath.
---@param map table<string, string> top-level Lua module -> config module
function M.module(map)
  for name, mod in pairs(map) do
    by_module[name] = mod
  end
end

-- Last-resort searcher: only reached when no other loader found the module,
-- i.e. the plugin that provides it is not on the runtimepath yet.
local loaders = package.loaders or package.searchers

local function searcher(name)
  local mod = by_module[name:match '^[^.]+']
  if not mod or done[mod] then return end

  M.load(mod)

  -- Normally the config module already required this module (its setup call),
  -- so reuse the cached value instead of running the chunk a second time.
  local cached = package.loaded[name]
  if cached ~= nil then
    return function() return cached end
  end

  -- Otherwise the plugin is on the runtimepath now: let the other loaders retry.
  for _, loader in ipairs(loaders) do
    if loader ~= searcher then
      local found = loader(name)
      if type(found) == 'function' then return found end
    end
  end
end

table.insert(loaders, searcher)

---Names of the config modules loaded so far (for debugging).
---@return string[]
function M.loaded()
  local names = vim.tbl_keys(done)
  table.sort(names)
  return names
end

return M
-- vim: ts=2 sts=2 sw=2 et
