local gh = require('util').gh

-- precognition.nvim - show motion targets before you move
--
-- Draws hint badges (w, b, e, ge, f, ...) where each motion would land, so you
-- can see the target before pressing the key. Toggle with <leader>up.
--
-- https://github.com/tris203/precognition.nvim
vim.pack.add { gh 'tris203/precognition.nvim' }
require('precognition').setup {
  startVisible = true,
}

-- <leader>u = UI toggles (which-key group) — toggle the motion hints.
vim.keymap.set('n', '<leader>up', function() require('precognition').toggle() end, { desc = 'Toggle Precognition' })

-- vim: ts=2 sts=2 sw=2 et
