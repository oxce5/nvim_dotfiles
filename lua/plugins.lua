-- Load plugin modules in order.
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
-- Plugins are eagerly loaded at startup; ordering below only matters where
-- noted (mini before devicon consumers, base16 before matugen in init.lua).

-- LSP
require 'plugins.lsp.lspconfig'
require 'plugins.lsp.jdtls' -- self-managed LSP (Java)
require 'plugins.lsp.rnvim' -- self-managed R session + language server

-- Code
require 'plugins.code.mini' -- mini.icons must precede devicon consumers (ui/*)
require 'plugins.code.treesitter'
require 'plugins.code.blink-cmp'
require 'plugins.code.conform'
require 'plugins.code.lint'
require 'plugins.code.debug'
require 'plugins.code.guess-indent'
require 'plugins.code.ts-comments'

-- Git
require 'plugins.git.gitsigns'

-- Navigation
require 'plugins.nav.telescope'
require 'plugins.nav.flash'
require 'plugins.nav.trouble'
require 'plugins.nav.grug-far'
require 'plugins.nav.neo-tree'

-- UI (base16 must be installed before matugen.setup() runs in init.lua)
require 'plugins.ui.base16'
require 'plugins.ui.which-key'
require 'plugins.ui.noice'
require 'plugins.ui.lualine'
require 'plugins.ui.indent-line'
require 'plugins.ui.todo-comments'
require 'plugins.ui.tiny-glimmer'
require 'plugins.ui.transparency'

-- vim: ts=2 sts=2 sw=2 et
