local function gh(repo) return 'https://github.com/' .. repo end

-- Useful plugin to show you pending keybinds.
vim.pack.add { gh 'folke/which-key.nvim' }
require('which-key').setup {
  delay = 0,
  icons = { mappings = vim.g.have_nerd_font },
  preset = 'helix',
  spec = {
    { '<leader>f', group = 'File/Find', mode = { 'n', 'v' } },
    { '<leader>s', group = 'Search', mode = { 'n', 'v' } },
    { '<leader>g', group = 'Git', mode = { 'n', 'v' } },
    { '<leader>gh', group = 'Git Hunk', mode = { 'n', 'v' } },
    { '<leader>c', group = 'Code', mode = { 'n', 'v' } },
    { '<leader>d', group = 'Debug', mode = { 'n', 'v' } },
    { '<leader>u', group = 'UI', mode = { 'n', 'v' } },
    { '<leader>x', group = 'Diagnostics/Quickfix', mode = { 'n', 'v' } },
    { '<leader>b', group = 'Buffer', mode = { 'n', 'v' } },
    { '<leader>t', group = 'Toggle', mode = { 'n', 'v' } },
    { '[', group = 'Prev' },
    { ']', group = 'Next' },
    { 'g', group = 'Goto' },
    { 'gs', group = 'Surround' },
  },
}

-- vim: ts=2 sts=2 sw=2 et