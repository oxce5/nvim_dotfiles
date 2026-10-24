local function gh(repo) return 'https://github.com/' .. repo end

-- mini.pairs - auto pairs for brackets, quotes, etc.
vim.pack.add { gh 'nvim-mini/mini.pairs' }

require('mini.pairs').setup {
  modes = { insert = true, command = true, terminal = false },
  skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
  skip_ts = { 'string' },
  skip_unbalanced = true,
  markdown = true,
}