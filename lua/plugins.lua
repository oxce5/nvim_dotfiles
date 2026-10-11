-- Load plugin modules in order.

require 'plugins.core.guess-indent'
require 'plugins.core.mini'
require 'plugins.core.telescope'
require 'plugins.core.debug'
require 'plugins.core.lspconfig'
require 'plugins.core.conform'
require 'plugins.core.blink-cmp'
require 'plugins.core.treesitter'

require 'plugins.ui.base16'
require 'plugins.ui.gitsigns'
require 'plugins.ui.which-key'
require 'plugins.ui.todo-comments'
require 'plugins.ui.neo-tree'
require 'plugins.ui.tiny-glimmer'
require 'plugins.ui.indent_line'
require 'plugins.ui.lualine'

-- require 'kickstart.plugins.lint'
-- require 'kickstart.plugins.autopairs'
-- require 'kickstart.plugins.gitsigns' -- adds gitsigns recommended keymaps
-- The following comments only work if you have downloaded the kickstart repo, not just copy pasted the

-- init.lua. If you want these files, they are in the repository, so you can just download them and
-- place them in the correct locations.

-- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for Kickstart
--
--  Here are some example plugins that I've included in the Kickstart repository.
--  Uncomment any of the lines below to enable them (you will need to restart nvim).
--
-- require 'kickstart.plugins.debug'

-- NOTE: You can add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
--
--  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
-- require 'custom.plugins'

-- vim: ts=2 sts=2 sw=2 et
