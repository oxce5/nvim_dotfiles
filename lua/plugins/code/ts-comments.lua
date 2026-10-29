local gh = require('util').gh

-- ts-comments.nvim - Treesitter-aware comments
vim.pack.add { gh 'folke/ts-comments.nvim' }

require('ts-comments').setup {}
