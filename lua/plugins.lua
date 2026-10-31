-- Load plugin modules.
--
-- Layout: lua/plugins/<category>/<feature>.lua
--   lsp/   - talks to language servers
--   code/  - changes how text is edited or checked (completion, format, lint,
--            debug, treesitter, pairs/textobjects, comments, indent detection)
--   git/   - version control
--   nav/   - finds things or moves you to them (pickers, motion, explorer,
--            diagnostics lists, search & replace)
--   ui/    - what you see (theme, statusline, cmdline, keymap hints, ...)
--
-- Each file installs its own plugins via vim.pack.add and calls .setup().
-- Most files are deferred through lua/lazy_load.lua; the sections below say
-- what must stay eager and why. Check what has loaded so far with:
--   :lua =require('lazy_load').loaded()

local lazy = require 'lazy_load'

-- [[ Eager: needed on the first frame, or before matugen runs at the end of init ]]
require 'plugins.ui.base16' -- first vim.pack call; the palette everything reads
require 'plugins.ui.transparency'
require 'plugins.ui.lualine'
require 'plugins.code.mini' -- mini.icons must precede devicon consumers (ui/*)
require 'plugins.ui.noice' -- ColorScheme autocmd must exist before matugen emits
require 'plugins.ui.tiny-glimmer' -- same
require 'plugins.code.treesitter' -- nvim-treesitter (main) doesn't support lazy loading
-- These define keymaps at module scope, so deferring them would leave the maps
-- undefined until first use. Both are cheap, so there is nothing to gain.
require 'plugins.code.debug'
require 'plugins.nav.neo-tree' -- also handles `nvim <dir>`

-- [[ First buffer: BufReadPre / BufNewFile ]]
-- blink.cmp goes before lspconfig so servers start with its capabilities.
-- The LSP modules register FileType autocmds themselves, so they must load
-- before the first FileType; telescope wires buffer-local maps via LspAttach,
-- so it must load before a server attaches.
lazy.event({ 'BufReadPre', 'BufNewFile' }, {
  'plugins.code.blink-cmp',
  'plugins.lsp.lspconfig',
  'plugins.lsp.jdtls', -- self-managed LSP (Java)
  'plugins.lsp.rnvim', -- self-managed R session + language server
  'plugins.nav.telescope',
  'plugins.code.conform',
  'plugins.code.lint',
  'plugins.code.guess-indent',
  'plugins.code.ts-comments',
  'plugins.git.gitsigns',
  'plugins.ui.todo-comments',
  'plugins.ui.rainbow-delimiters', -- defines Rainbow* groups before indent-line
  'plugins.ui.indent-line',
})

-- [[ Idle: right after startup, once VimEnter has fired ]]
-- These define many keymaps inside their own module, so a command trigger
-- would lose them until first use. Loading just after startup keeps them.
lazy.idle {
  'plugins.nav.flash',
  'plugins.nav.trouble',
  'plugins.nav.grug-far',
  'plugins.ui.which-key',
  'plugins.nav.precognition',
}

-- [[ On first use ]]
-- Trouble's keymaps are <cmd>Trouble ...<cr>; the stub covers the gap before
-- the idle load above.
lazy.cmd('Trouble', 'plugins.nav.trouble')

-- Keymaps that call require() in their body land here while the plugin is not
-- on the runtimepath yet.
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
