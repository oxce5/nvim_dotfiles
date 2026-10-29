-- Neovim configuration entry point.
--
-- Layout:
--   lua/config/    - options, autocmds, global keymaps (no plugins)
--   lua/util/      - shared helpers
--   lua/pack.lua   - vim.pack build hooks
--   lua/plugins/   - plugin specs, grouped by lsp/code/git/nav/ui
--   lua/matugen.lua - generated base16 palette (see templates/)
--
-- Load order matters:
--   1. config  (leader key must be set before any plugin loads)
--   2. pack    (PackChanged build hooks must exist before plugins install)
--   3. plugins (each spec calls vim.pack.add + setup)
--   4. matugen (applies the palette; needs base16-nvim from plugins/ui)

require 'config'
require 'pack'
require 'plugins'

local ok, matugen = pcall(require, 'matugen')
if ok then matugen.setup() end

-- vim: ts=2 sts=2 sw=2 et
