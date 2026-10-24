-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic Config & Keymaps
--  See `:help vim.diagnostic.Opts`
vim.diagnostic.config {
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = { min = vim.diagnostic.severity.WARN } },
  virtual_text = true,
  virtual_lines = false,
  jump = {
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float {
        bufnr = bufnr,
        scope = 'cursor',
        focus = false,
      }
    end,
  },
}

-- Exit terminal mode in the builtin terminal with a shortcut
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

-- ============================================================================
-- LazyVim-style Leader Key Groups
-- ============================================================================

local map = vim.keymap.set

-- ============================================================================
-- <leader>g - Git (gitsigns)
-- ============================================================================
map('n', '<leader>gg', '<cmd>Neotree float git_status<cr>', { desc = 'Git Status' })
map('n', '<leader>ghs', '<cmd>Gitsigns stage_hunk<cr>', { desc = 'Stage Hunk' })
map('n', '<leader>ghr', '<cmd>Gitsigns reset_hunk<cr>', { desc = 'Reset Hunk' })
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

-- Git navigation
map('n', ']c', function()
  if vim.wo.diff then vim.cmd.normal { ']c', bang = true } else require('gitsigns').nav_hunk 'next' end
end, { desc = 'Next Git Change' })
map('n', '[c', function()
  if vim.wo.diff then vim.cmd.normal { '[c', bang = true } else require('gitsigns').nav_hunk 'prev' end
end, { desc = 'Prev Git Change' })

-- ============================================================================
-- <leader>c - Code (LSP, conform, lint)
-- ============================================================================
map({ 'n', 'x' }, '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code Action' })
map('n', '<leader>cr', vim.lsp.buf.rename, { desc = 'Rename' })
map({ 'n', 'v' }, '<leader>cf', function() require('conform').format { async = true } end, { desc = 'Format Buffer' })
map('n', '<leader>ci', function() require('telescope').extensions.lsp.config() end, { desc = 'LSP Info' })
map('n', '<leader>cd', vim.diagnostic.open_float, { desc = 'Line Diagnostics' })
map('n', '<leader>cD', '<cmd>Trouble diagnostics toggle<cr>', { desc = 'Buffer Diagnostics (Trouble)' })
map('n', '<leader>cs', '<cmd>Trouble symbols toggle<cr>', { desc = 'Symbols (Trouble)' })
map('n', '<leader>cS', '<cmd>Trouble lsp toggle<cr>', { desc = 'LSP References/Definitions (Trouble)' })
map('n', '<leader>ci', '<cmd>LspInfo<cr>', { desc = 'LSP Info' })
map('n', '<leader>cI', '<cmd>Mason<cr>', { desc = 'Mason' })
map('n', '<leader>cl', '<cmd>LspLog<cr>', { desc = 'LSP Log' })

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
-- <leader>d - Debug (DAP)
-- ============================================================================
map('n', '<leader>dc', '<cmd>DapContinue<cr>', { desc = 'Continue/Start' })
map('n', '<leader>db', '<cmd>DapToggleBreakpoint<cr>', { desc = 'Toggle Breakpoint' })
map('n', '<leader>dB', function() require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, { desc = 'Breakpoint Condition' })
map('n', '<leader>dr', '<cmd>DapRestart<cr>', { desc = 'Restart' })
map('n', '<leader>du', '<cmd>DapUiToggle<cr>', { desc = 'Toggle DAP UI' })
map('n', '<leader>de', '<cmd>DapEval<cr>', { desc = 'Evaluate' })
map('n', '<F5>', '<cmd>DapContinue<cr>', { desc = 'Debug: Continue' })
map('n', '<F1>', '<cmd>DapStepInto<cr>', { desc = 'Debug: Step Into' })
map('n', '<F2>', '<cmd>DapStepOver<cr>', { desc = 'Debug: Step Over' })
map('n', '<F3>', '<cmd>DapStepOut<cr>', { desc = 'Debug: Step Out' })
map('n', '<F7>', '<cmd>DapUiToggle<cr>', { desc = 'Debug: Toggle UI' })

-- ============================================================================
-- <leader>u - UI Toggles
-- ============================================================================
map('n', '<leader>un', function() require('noice').cmd 'dismiss' end, { desc = 'Dismiss Notifications' })
map('n', '<leader>uh', '<cmd>nohlsearch<cr>', { desc = 'Clear Highlights' })
map('n', '<leader>uG', function() require('gitsigns').toggle_signs() end, { desc = 'Toggle Git Signs' })
map('n', '<leader>ul', '<cmd>set list!<cr>', { desc = 'Toggle List Chars' })
map('n', '<leader>uw', '<cmd>set wrap!<cr>', { desc = 'Toggle Wrap' })
map('n', '<leader>ur', '<cmd>set relativenumber!<cr>', { desc = 'Toggle Relative Numbers' })
map('n', '<leader>uc', '<cmd>set cursorline!<cr>', { desc = 'Toggle Cursor Line' })

-- ============================================================================
-- <leader>x - Diagnostics/Quickfix (Trouble)
-- ============================================================================
map('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', { desc = 'Diagnostics (Trouble)' })
map('n', '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', { desc = 'Buffer Diagnostics (Trouble)' })
map('n', '<leader>xL', '<cmd>Trouble loclist toggle<cr>', { desc = 'Location List (Trouble)' })
map('n', '<leader>xQ', '<cmd>Trouble qflist toggle<cr>', { desc = 'Quickfix List (Trouble)' })
map('n', '<leader>xd', vim.diagnostic.setloclist, { desc = 'Quickfix Diagnostics' })
map('n', '<leader>xq', '<cmd>copen<cr>', { desc = 'Open Quickfix' })
map('n', '<leader>xc', '<cmd>cclose<cr>', { desc = 'Close Quickfix' })

-- Quickfix/Trouble navigation
map('n', '[q', function()
  if require('trouble').is_open() then
    require('trouble').prev { skip_groups = true, jump = true }
  else
    local ok, err = pcall(vim.cmd.cprev)
    if not ok then vim.notify(err, vim.log.levels.ERROR) end
  end
end, { desc = 'Previous Quickfix/Trouble' })
map('n', ']q', function()
  if require('trouble').is_open() then
    require('trouble').next { skip_groups = true, jump = true }
  else
    local ok, err = pcall(vim.cmd.cnext)
    if not ok then vim.notify(err, vim.log.levels.ERROR) end
  end
end, { desc = 'Next Quickfix/Trouble' })

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

-- ============================================================================
-- Neo-tree
-- ============================================================================
map('n', '\\', '<cmd>Neotree reveal<cr>', { desc = 'NeoTree Reveal' })
map('n', '<leader>e', '<cmd>Neotree toggle<cr>', { desc = 'Toggle NeoTree' })
map('n', '<leader>E', '<cmd>Neotree float<cr>', { desc = 'NeoTree Float' })

-- ============================================================================
-- Lint
-- ============================================================================
map('n', '<leader>cl', function() require('lint').try_lint() end, { desc = 'Lint Buffer' })

-- vim: ts=2 sts=2 sw=2 et