-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Debug adapters (e.g. delve for Go) are expected on $PATH — Nix manages them.

local gh = require('util').gh

vim.pack.add {
  gh 'mfussenegger/nvim-dap',
  gh 'rcarriga/nvim-dap-ui',
  gh 'nvim-neotest/nvim-nio',
  gh 'leoluz/nvim-dap-go',
}

local dap = require 'dap'
local dapui = require 'dapui'

-- Debugging keymaps (which-key group: <leader>d = Debug)
local map = vim.keymap.set
map('n', '<leader>dc', function() dap.continue() end, { desc = 'Continue/Start' })
map('n', '<leader>db', function() dap.toggle_breakpoint() end, { desc = 'Toggle Breakpoint' })
map('n', '<leader>dB', function() dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, { desc = 'Breakpoint Condition' })
map('n', '<leader>dr', function() dap.restart() end, { desc = 'Restart' })
map('n', '<leader>du', function() dapui.toggle() end, { desc = 'Toggle DAP UI' })
map('n', '<leader>de', function() dapui.eval() end, { desc = 'Evaluate' })
-- Function keys as universal debug controls
map('n', '<F5>', function() dap.continue() end, { desc = 'Debug: Start/Continue' })
map('n', '<F1>', function() dap.step_into() end, { desc = 'Debug: Step Into' })
map('n', '<F2>', function() dap.step_over() end, { desc = 'Debug: Step Over' })
map('n', '<F3>', function() dap.step_out() end, { desc = 'Debug: Step Out' })
map('n', '<F7>', function() dapui.toggle() end, { desc = 'Debug: Toggle UI' })

-- Dap UI setup
-- For more information, see |:help nvim-dap-ui|
---@diagnostic disable-next-line: missing-fields
dapui.setup {
  -- Set icons to characters that are more likely to work in every terminal.
  icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
  ---@diagnostic disable-next-line: missing-fields
  controls = {
    icons = {
      pause = '⏸',
      play = '▶',
      step_into = '⏎',
      step_over = '⏭',
      step_out = '⏮',
      step_back = 'b',
      run_last = '▶▶',
      terminate = '⏹',
      disconnect = '⏏',
    },
  },
}

-- Change breakpoint icons
-- vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
-- vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
-- local breakpoint_icons = vim.g.have_nerd_font
--     and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
--   or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
-- for type, icon in pairs(breakpoint_icons) do
--   local tp = 'Dap' .. type
--   local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
--   vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
-- end

dap.listeners.after.event_initialized['dapui_config'] = dapui.open
dap.listeners.before.event_terminated['dapui_config'] = dapui.close
dap.listeners.before.event_exited['dapui_config'] = dapui.close

-- Install golang specific config (requires `delve` on $PATH)
require('dap-go').setup {
  delve = {
    -- On Windows delve must be run attached or it crashes.
    -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
    detached = vim.fn.has 'win32' == 0,
  },
}

-- vim: ts=2 sts=2 sw=2 et
