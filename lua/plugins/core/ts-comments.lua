local function gh(repo) return 'https://github.com/' .. repo end

-- ts-comments.nvim - Treesitter-aware comments
vim.pack.add { gh 'folke/ts-comments.nvim' }

require('ts-comments').setup {}