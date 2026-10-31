-- Load plugin modules from lua/plugins/<category>/<feature>.lua
--   lsp/, code/, git/, nav/, ui/
--
-- Each file calls vim.pack.add() and .setup().
-- Most files are deferred via lazy_load.lua; sections below say what stays eager and why.
-- Check loaded with: :lua =require('lazy_load').loaded()

local lazy = require 'lazy_load'

-- Eager: needed on first frame, or before matugen emits.
require 'plugins.ui.base16' -- first vim.pack call; the palette everything reads
require 'plugins.ui.transparency'
require 'plugins.ui.lualine'
require 'plugins.code.mini' -- mini.icons before devicon consumers
require 'plugins.ui.noice' -- ColorScheme autocmd before matugen emits
require 'plugins.ui.tiny-glimmer' -- same
require 'plugins.code.treesitter' -- nvim-treesitter (main) doesn't support lazy
require 'plugins.code.debug' -- keymaps at module scope
require 'plugins.nav.neo-tree' -- keymaps at module scope + directory handling

-- First buffer or first edit: BufReadPre / BufNewFile / InsertEnter
-- InsertEnter covers unnamed buffers (like :e). blink.cmp before lspconfig.
-- telescope wires buffer-local maps via LspAttach; LSP modules register FileType.
lazy.event({ 'BufReadPre', 'BufNewFile', 'InsertEnter' }, {
  'plugins.code.blink-cmp',
  'plugins.lsp.lspconfig',
  'plugins.lsp.jdtls', -- Java
  'plugins.lsp.rnvim', -- R
  'plugins.nav.telescope',
  'plugins.code.conform',
  'plugins.code.lint',
  'plugins.code.guess-indent',
  'plugins.code.ts-comments',
  'plugins.git.gitsigns',
  'plugins.ui.todo-comments',
  'plugins.ui.rainbow-delimiters', -- Rainbow* before indent-line
  'plugins.ui.indent-line',
})

-- Idle: after startup (once VimEnter fires)
-- These define keymaps at module scope; command triggers would lose them.
lazy.idle {
  'plugins.nav.flash',
  'plugins.nav.trouble',
  'plugins.nav.grug-far',
  'plugins.ui.which-key',
  'plugins.nav.precognition',
}

-- On first use: Trouble command stub (keymaps are <cmd>Trouble ...<cr>).
lazy.cmd('Trouble', 'plugins.nav.trouble')

-- Keymaps that call require() in their body land here while the plugin is not on the runtimepath yet.
lazy.module {
  conform = 'plugins.code.conform',
  flash = 'plugins.nav.flash',
  gitsigns = 'plugins.git.gitsigns',
  ['grug-far'] = 'plugins.nav.grug-far',
  lint = 'plugins.code.lint',
  precognition = 'plugins.nav.precognition',
  telescope = 'plugins.nav.telescope',
  trouble = 'plugins.nav.trouble',
  ['which-key'] = 'plugins.ui.which-key',
}

-- vim: ts=2 sts=2 sw=2 et
