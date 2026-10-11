 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#131318',
    base01 = '#1f1f25',
    base02 = '#2a292f',
    base03 = '#918f9a',
    base04 = '#c8c5d0',
    base05 = '#e5e1e9',
    base06 = '#e5e1e9',
    base07 = '#e5e1e9',
    base08 = '#ffb4ab',
    base09 = '#eab9d2',
    base0A = '#c6c4dd',
    base0B = '#c2c1ff',
    base0C = '#eab9d2',
    base0D = '#c2c1ff',
    base0E = '#c6c4dd',
    base0F = '#e3e0f9',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- telescope.nvim
  hi('TelescopeNormal',         { fg = '#e5e1e9',          bg = '#131318' })
  hi('TelescopeBorder',         { fg = '#918f9a',             bg = '#131318' })
  hi('TelescopePromptNormal',   { fg = '#e5e1e9',          bg = '#131318' })
  hi('TelescopePromptBorder',   { fg = '#918f9a',             bg = '#131318' })
  hi('TelescopePromptPrefix',   { fg = '#c2c1ff',             bg = '#131318' })
  hi('TelescopePromptCounter',  { fg = '#c8c5d0',  bg = '#131318' })
  hi('TelescopePromptTitle',    { fg = '#131318',             bg = '#c2c1ff' })
  hi('TelescopePreviewTitle',   { fg = '#131318',             bg = '#c6c4dd' })
  hi('TelescopeResultsTitle',   { fg = '#131318',             bg = '#eab9d2' })
  hi('TelescopeSelection',      { fg = '#e5e1e9',          bg = '#2a292f' })
  hi('TelescopeSelectionCaret', { fg = '#c2c1ff',             bg = '#2a292f' })
  hi('TelescopeMatching',       { fg = '#c2c1ff',             bold = true })

  -- mini.pick
  hi('MiniPickNormal',         { fg = '#e5e1e9',          bg = '#131318' })
  hi('MiniPickBorder',         { fg = '#918f9a',             bg = '#131318' })
  hi('MiniPickPrompt',   { fg = '#e5e1e9',          bg = '#131318' })
  hi('MiniPickPromptPrefix',   { fg = '#c2c1ff',             bg = '#131318' })
  hi('MiniPickBorderText',    { fg = '#131318',             bg = '#c2c1ff' })
  hi('MiniPickMatchCurrent',      { fg = '#e5e1e9',          bg = '#2a292f' })
  hi('MiniPickPromptCaret', { fg = '#c2c1ff',             bg = '#2a292f' })
  hi('MiniPickMatchRanges',       { fg = '#c2c1ff',             bold = true })

  -- base16-colorscheme now exports the palette as vim.g.base16_gui00..0F.
  -- Plugins that snapshot colors at setup time (lualine) must rebuild; they
  -- already listen for ColorScheme.
  vim.api.nvim_exec_autocmds('ColorScheme', { modeline = false })
end

-- Register a signal handler for SIGUSR1 (matugen updates).
-- The handler re-requires this module, which re-runs the code below, so the
-- previous handle is stopped first; otherwise handlers double on every signal.
if _G.__matugen_signal then
  _G.__matugen_signal:stop()
  _G.__matugen_signal:close()
end

local signal = vim.uv.new_signal()
_G.__matugen_signal = signal
signal:start(
  'sigusr1',
  vim.schedule_wrap(function()
    package.loaded['matugen'] = nil
    require('matugen').setup()
  end)
)

return M
