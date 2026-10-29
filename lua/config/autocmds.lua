-- Global autocmds not tied to any plugin.

-- Highlight when yanking (copying) text
--  See `:help vim.hl.on_yank`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

-- vim: ts=2 sts=2 sw=2 et
