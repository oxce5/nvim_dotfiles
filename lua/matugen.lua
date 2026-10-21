 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#131318',
    base01 = '#201f25',
    base02 = '#2a292f',
    base03 = '#928f99',
    base04 = '#c8c5d0',
    base05 = '#e5e1e9',
    base06 = '#e5e1e9',
    base07 = '#e5e1e9',
    base08 = '#ffb4ab',
    base09 = '#ebb9d0',
    base0A = '#c7c4dc',
    base0B = '#c5c0ff',
    base0C = '#ebb9d0',
    base0D = '#c5c0ff',
    base0E = '#c7c4dc',
    base0F = '#e4dff9',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- telescope.nvim
  hi('TelescopeNormal',         { fg = '#e5e1e9',          bg = '#131318' })
  hi('TelescopeBorder',         { fg = '#928f99',             bg = '#131318' })
  hi('TelescopePromptNormal',   { fg = '#e5e1e9',          bg = '#131318' })
  hi('TelescopePromptBorder',   { fg = '#928f99',             bg = '#131318' })
  hi('TelescopePromptPrefix',   { fg = '#c5c0ff',             bg = '#131318' })
  hi('TelescopePromptCounter',  { fg = '#c8c5d0',  bg = '#131318' })
  hi('TelescopePromptTitle',    { fg = '#131318',             bg = '#c5c0ff' })
  hi('TelescopePreviewTitle',   { fg = '#131318',             bg = '#c7c4dc' })
  hi('TelescopeResultsTitle',   { fg = '#131318',             bg = '#ebb9d0' })
  hi('TelescopeSelection',      { fg = '#e5e1e9',          bg = '#2a292f' })
  hi('TelescopeSelectionCaret', { fg = '#c5c0ff',             bg = '#2a292f' })
  hi('TelescopeMatching',       { fg = '#c5c0ff',             bold = true })

  -- mini.pick
  hi('MiniPickNormal',         { fg = '#e5e1e9',          bg = '#131318' })
  hi('MiniPickBorder',         { fg = '#928f99',             bg = '#131318' })
  hi('MiniPickPrompt',   { fg = '#e5e1e9',          bg = '#131318' })
  hi('MiniPickPromptPrefix',   { fg = '#c5c0ff',             bg = '#131318' })
  hi('MiniPickBorderText',    { fg = '#131318',             bg = '#c5c0ff' })
  hi('MiniPickMatchCurrent',      { fg = '#e5e1e9',          bg = '#2a292f' })
  hi('MiniPickPromptCaret', { fg = '#c5c0ff',             bg = '#2a292f' })
  hi('MiniPickMatchRanges',       { fg = '#c5c0ff',             bold = true })
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
