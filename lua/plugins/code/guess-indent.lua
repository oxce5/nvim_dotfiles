local gh = require('util').gh

-- [[ Installing and Configuring Plugins ]]
--
-- To install a plugin simply call `vim.pack.add` with its git url.
-- This will download the default branch of the plugin, which will usually be `main` or `master`
-- You can also have more advanced specs, which we will talk about later.
--
-- For most plugins its not enough to install them, you also need to call their `.setup()` to start them.
--
-- For example, lets say we want to install `guess-indent.nvim` - a plugin for
-- automatically detecting and setting the indentation.
--
-- We first install it from https://github.com/NMAC427/guess-indent.nvim
-- and then call its `setup()` function to start it with default settings.
vim.pack.add { gh 'NMAC427/guess-indent.nvim' }
require('guess-indent').setup {
  -- We're a strict 2-space (expandtab) setup, so never let detection switch a
  -- buffer to hard tabs. Default on_tab_options sets expandtab=false, which
  -- made tab-indented files (e.g. Java) keep producing \t bytes — those render
  -- as 8 cols in `cat`/yank regardless of 'tabstop'. With {} a detected-tab
  -- file just keeps the global expandtab/shiftwidth; detection still applies
  -- the *width* for space-indented files via on_space_options.
  on_tab_options = {},
}

-- vim: ts=2 sts=2 sw=2 et
