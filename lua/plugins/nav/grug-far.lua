local gh = require('util').gh

-- grug-far.nvim - search and replace in multiple files
vim.pack.add { gh 'MagicDuck/grug-far.nvim' }

require('grug-far').setup {
  headerMaxWidth = 80,
}

vim.keymap.set({ 'n', 'x' }, '<leader>sr', function()
  local grug = require 'grug-far'
  local ext = vim.bo.buftype == '' and vim.fn.expand '%:e'
  grug.open {
    transient = true,
    prefills = {
      filesFilter = ext and ext ~= '' and '*.' .. ext or nil,
    },
  }
end, { desc = 'Search and Replace' })
