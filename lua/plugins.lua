-- Load plugin modules in order.

-- Core plugins
require 'plugins.core.guess-indent'
require 'plugins.core.mini'
require 'plugins.core.mini-pairs'
require 'plugins.core.ts-comments'
require 'plugins.core.telescope'
require 'plugins.core.debug'
require 'plugins.core.lspconfig'
require 'plugins.core.conform'
require 'plugins.core.blink-cmp'
require 'plugins.core.treesitter'
require 'plugins.core.lint'

-- Editor plugins
require 'plugins.editor.grug-far'
require 'plugins.editor.flash'
require 'plugins.editor.trouble'

-- UI plugins
require 'plugins.ui.base16'
require 'plugins.ui.gitsigns'
require 'plugins.ui.which-key'
require 'plugins.ui.todo-comments'
require 'plugins.ui.neo-tree'
require 'plugins.ui.noice'
require 'plugins.ui.tiny-glimmer'
require 'plugins.ui.indent_line'
require 'plugins.ui.lualine'
require 'plugins.ui.transparency'

-- vim: ts=2 sts=2 sw=2 et
