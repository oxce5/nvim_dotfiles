local gh = require('util').gh

-- Adds git related signs to the gutter, as well as utilities for managing changes
--
-- See `:help gitsigns` to understand what each configuration key does.
--
-- Keymap ownership:
--  - Global <leader>gh* action maps and toggles: lua/config/keymaps.lua
--  - Buffer-local ]c/[c hunk navigation and the `ih` text object: below
vim.pack.add { gh 'lewis6991/gitsigns.nvim' }
require('gitsigns').setup {
  signs = {
    add = { text = '+' }, ---@diagnostic disable-line: missing-fields
    change = { text = '~' }, ---@diagnostic disable-line: missing-fields
    delete = { text = '_' }, ---@diagnostic disable-line: missing-fields
    topdelete = { text = '‾' }, ---@diagnostic disable-line: missing-fields
    changedelete = { text = '~' }, ---@diagnostic disable-line: missing-fields
  },
  on_attach = function(bufnr)
    local gitsigns = require 'gitsigns'

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation (buffer-local so it wins over any global ]c/[c)
    map('n', ']c', function()
      if vim.wo.diff then
        vim.cmd.normal { ']c', bang = true }
      else
        gitsigns.nav_hunk 'next'
      end
    end, { desc = 'Jump to next git [c]hange' })

    map('n', '[c', function()
      if vim.wo.diff then
        vim.cmd.normal { '[c', bang = true }
      else
        gitsigns.nav_hunk 'prev'
      end
    end, { desc = 'Jump to previous git [c]hange' })

    -- Text object: select a hunk
    map({ 'o', 'x' }, 'ih', gitsigns.select_hunk, { desc = 'Inside hunk' })
  end,
}

-- vim: ts=2 sts=2 sw=2 et
