-- [[ Basic Keymaps ]]
--  Only genuinely-global, non-plugin maps live here.
--  Plugin-owned keymaps (formatting, linting, LSP attach, git, trouble, ...)
--  are defined in their plugin file under lua/plugins/.
--
--  See `:help vim.keymap.set()`

local map = vim.keymap.set

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
map('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Exit terminal mode in the builtin terminal with a shortcut
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
map('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
map('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
map('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
map('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- ============================================================================
-- LazyVim-style Leader Key Groups
--  (groups themselves are declared in plugins/ui/which-key.lua)
-- ============================================================================

-- ============================================================================
-- <leader>g - Git
--  Hunk actions/signs (gitsigns) are global; ]c/[c and `ih` live in
--  plugins/git/gitsigns.lua as buffer-local maps.
-- ============================================================================
map('n', '<leader>gg', '<cmd>Neotree float git_status<cr>', { desc = 'Git Status' })
map({ 'n', 'v' }, '<leader>ghs', '<cmd>Gitsigns stage_hunk<cr>', { desc = 'Stage Hunk' })
map({ 'n', 'v' }, '<leader>ghr', '<cmd>Gitsigns reset_hunk<cr>', { desc = 'Reset Hunk' })
map('n', '<leader>ghS', '<cmd>Gitsigns stage_buffer<cr>', { desc = 'Stage Buffer' })
map('n', '<leader>ghu', '<cmd>Gitsigns undo_stage_hunk<cr>', { desc = 'Undo Stage Hunk' })
map('n', '<leader>ghR', '<cmd>Gitsigns reset_buffer<cr>', { desc = 'Reset Buffer' })
map('n', '<leader>ghp', '<cmd>Gitsigns preview_hunk<cr>', { desc = 'Preview Hunk' })
map('n', '<leader>ghi', '<cmd>Gitsigns preview_hunk_inline<cr>', { desc = 'Preview Hunk Inline' })
map('n', '<leader>ghb', function() require('gitsigns').blame_line { full = true } end, { desc = 'Blame Line' })
map('n', '<leader>ghB', '<cmd>Gitsigns blame<cr>', { desc = 'Blame Buffer' })
map('n', '<leader>ghd', '<cmd>Gitsigns diffthis<cr>', { desc = 'Diff Against Index' })
map('n', '<leader>ghD', function() require('gitsigns').diffthis '~' end, { desc = 'Diff Against Last Commit' })
map('n', '<leader>ghq', '<cmd>Gitsigns setqflist<cr>', { desc = 'Quickfix List (File)' })
map('n', '<leader>ghQ', function() require('gitsigns').setqflist 'all' end, { desc = 'Quickfix List (All)' })
map('n', '<leader>tb', '<cmd>Gitsigns toggle_current_line_blame<cr>', { desc = 'Toggle Git Blame Line' })
map('n', '<leader>tw', '<cmd>Gitsigns toggle_word_diff<cr>', { desc = 'Toggle Word Diff' })
map('n', '<leader>uG', function() require('gitsigns').toggle_signs() end, { desc = 'Toggle Git Signs' })

-- ============================================================================
-- <leader>c - Code
--  Format (<leader>cf), lint (<leader>cl) and Trouble maps are owned by their
--  plugin files; LSP buffer maps are attached via LspAttach (telescope.lua).
-- ============================================================================
map({ 'n', 'x' }, '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code Action' })
map('n', '<leader>cr', vim.lsp.buf.rename, { desc = 'Rename' })
map('n', '<leader>cd', vim.diagnostic.open_float, { desc = 'Line Diagnostics' })
map('n', '<leader>ci', '<cmd>LspInfo<cr>', { desc = 'LSP Info' })
map('n', '<leader>cL', '<cmd>LspLog<cr>', { desc = 'LSP Log' })

-- LSP goto (global fallbacks - telescope provides buffer-local ones via LspAttach)
map('n', 'gd', vim.lsp.buf.definition, { desc = 'Goto Definition' })
map('n', 'gr', vim.lsp.buf.references, { desc = 'References', nowait = true })
map('n', 'gI', vim.lsp.buf.implementation, { desc = 'Goto Implementation' })
map('n', 'gy', vim.lsp.buf.type_definition, { desc = 'Goto Type Definition' })
map('n', 'gD', vim.lsp.buf.declaration, { desc = 'Goto Declaration' })
map('n', 'K', vim.lsp.buf.hover, { desc = 'Hover' })
map('n', 'gK', vim.lsp.buf.signature_help, { desc = 'Signature Help' })
map('i', '<c-k>', vim.lsp.buf.signature_help, { desc = 'Signature Help' })

-- ============================================================================
-- <leader>u - UI Toggles
-- ============================================================================
map('n', '<leader>un', function() require('noice').cmd 'dismiss' end, { desc = 'Dismiss Notifications' })
map('n', '<leader>uh', '<cmd>nohlsearch<cr>', { desc = 'Clear Highlights' })
map('n', '<leader>ul', '<cmd>set list!<cr>', { desc = 'Toggle List Chars' })
map('n', '<leader>uw', '<cmd>set wrap!<cr>', { desc = 'Toggle Wrap' })
map('n', '<leader>ur', '<cmd>set relativenumber!<cr>', { desc = 'Toggle Relative Numbers' })
map('n', '<leader>uc', '<cmd>set cursorline!<cr>', { desc = 'Toggle Cursor Line' })

-- ============================================================================
-- <leader>x - Diagnostics/Quickfix
--  Trouble toggles and [q/]q navigation live in plugins/nav/trouble.lua.
-- ============================================================================
map('n', '<leader>xd', vim.diagnostic.setloclist, { desc = 'Quickfix Diagnostics' })
map('n', '<leader>xq', '<cmd>copen<cr>', { desc = 'Open Quickfix' })
map('n', '<leader>xc', '<cmd>cclose<cr>', { desc = 'Close Quickfix' })

-- ============================================================================
-- Diagnostic navigation
-- ============================================================================
map('n', '[d', vim.diagnostic.goto_prev, { desc = 'Previous Diagnostic' })
map('n', ']d', vim.diagnostic.goto_next, { desc = 'Next Diagnostic' })
map('n', '[e', function() vim.diagnostic.goto_prev { severity = vim.diagnostic.severity.ERROR } end, { desc = 'Previous Error' })
map('n', ']e', function() vim.diagnostic.goto_next { severity = vim.diagnostic.severity.ERROR } end, { desc = 'Next Error' })

-- ============================================================================
-- Buffer navigation
-- ============================================================================
map('n', '[b', '<cmd>bprevious<cr>', { desc = 'Previous Buffer' })
map('n', ']b', '<cmd>bnext<cr>', { desc = 'Next Buffer' })
map('n', '<leader>bd', '<cmd>bdelete<cr>', { desc = 'Delete Buffer' })
map('n', '<leader>bD', '<cmd>bdelete!<cr>', { desc = 'Force Delete Buffer' })

-- vim: ts=2 sts=2 sw=2 et
