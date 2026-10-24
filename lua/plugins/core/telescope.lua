local function gh(repo) return 'https://github.com/' .. repo end

-- [[ Fuzzy Finder (files, lsp, etc) ]]
vim.pack.add {
  gh 'nvim-lua/plenary.nvim',
  gh 'nvim-telescope/telescope.nvim',
  gh 'nvim-telescope/telescope-ui-select.nvim',
}
if vim.fn.executable 'make' == 1 then vim.pack.add { gh 'nvim-telescope/telescope-fzf-native.nvim' } end

require('telescope').setup {
  extensions = {
    ['ui-select'] = { require('telescope.themes').get_dropdown() },
  },
}

pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'ui-select')

local builtin = require 'telescope.builtin'
local map = vim.keymap.set

-- <leader>f - File/Find
map('n', '<leader>ff', builtin.find_files, { desc = 'Find Files' })
map('n', '<leader>fg', builtin.live_grep, { desc = 'Live Grep' })
map('n', '<leader>fb', builtin.buffers, { desc = 'Buffers' })
map('n', '<leader>fr', builtin.oldfiles, { desc = 'Recent Files' })
map('n', '<leader>fh', builtin.help_tags, { desc = 'Help Tags' })
map('n', '<leader>fk', builtin.keymaps, { desc = 'Keymaps' })
map('n', '<leader>fc', builtin.commands, { desc = 'Commands' })
map('n', '<leader>fs', builtin.builtin, { desc = 'Select Telescope' })
map('n', '<leader>f/', builtin.current_buffer_fuzzy_find, { desc = 'Search in Buffer' })
map('n', '<leader>fn', function() builtin.find_files { cwd = vim.fn.stdpath 'config', follow = true } end, { desc = 'Neovim Config Files' })
map('n', '<leader><leader>', builtin.buffers, { desc = 'Find Buffers' })

-- <leader>s - Search
map({ 'n', 'v' }, '<leader>sw', builtin.grep_string, { desc = 'Search Word' })
map('n', '<leader>sd', builtin.diagnostics, { desc = 'Search Diagnostics' })
map('n', '<leader>sr', builtin.resume, { desc = 'Resume Search' })
map('n', '<leader>s.', builtin.oldfiles, { desc = 'Recent Files' })
map('n', '<leader>s/', function()
  builtin.live_grep { grep_open_files = true, prompt_title = 'Live Grep in Open Files' }
end, { desc = 'Grep in Open Files' })
map('n', '<leader>sc', builtin.commands, { desc = 'Commands' })
map('n', '<leader>sk', builtin.keymaps, { desc = 'Keymaps' })

-- Git
map('n', '<leader>gc', builtin.git_commits, { desc = 'Git Commits' })
map('n', '<leader>gb', builtin.git_branches, { desc = 'Git Branches' })
map('n', '<leader>gf', builtin.git_files, { desc = 'Git Files' })
map('n', '<leader>gs', builtin.git_status, { desc = 'Git Status' })

-- LSP (buffer-local via LspAttach)
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
  callback = function(event)
    local buf = event.buf
    map('n', 'grr', builtin.lsp_references, { buffer = buf, desc = 'Goto References' })
    map('n', 'gri', builtin.lsp_implementations, { buffer = buf, desc = 'Goto Implementation' })
    map('n', 'grd', builtin.lsp_definitions, { buffer = buf, desc = 'Goto Definition' })
    map('n', 'gO', builtin.lsp_document_symbols, { buffer = buf, desc = 'Document Symbols' })
    map('n', 'gW', builtin.lsp_dynamic_workspace_symbols, { buffer = buf, desc = 'Workspace Symbols' })
    map('n', 'grt', builtin.lsp_type_definitions, { buffer = buf, desc = 'Goto Type Definition' })
  end,
})

-- Buffer fuzzy find
map('n', '<leader>/', function()
  builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown { winblend = 10, previewer = false })
end, { desc = 'Search in Buffer' })

-- vim: ts=2 sts=2 sw=2 et