-- Indent guides + scope line.
--
-- `lukas-reineke/indent-blankline.nvim` draws the guides. Plain indent levels
-- are a recessive gray so they stay out of the way; the *scope* line (the
-- indent of the block the cursor is in) uses the same rainbow palette as
-- rainbow-delimiters so it stands out and matches the surrounding brackets.
--
-- The rainbow groups (RainbowRed, ...) are defined in ui/rainbow-delimiters.lua
-- as fixed hues — load that file first so they exist when ibl.setup() resolves
-- the scope highlight below.
-- See `:help ibl`

vim.pack.add { 'https://github.com/lukas-reineke/indent-blankline.nvim' }

local hooks = require 'ibl.hooks'

-- The same ordered hue list rainbow-delimiters cycles through.
local rainbow = { 'RainbowRed', 'RainbowYellow', 'RainbowBlue', 'RainbowOrange', 'RainbowGreen', 'RainbowViolet', 'RainbowCyan' }

-- Keep the plain indent guides gray. HIGHLIGHT_SETUP runs before ibl fills its
-- builtin groups, and IblIndent is only auto-filled when unset — so setting it
-- here wins. Re-runs on ColorScheme (emitted by matugen.setup()).
hooks.register(hooks.type.HIGHLIGHT_SETUP, function() vim.api.nvim_set_hl(0, 'IblIndent', { fg = vim.g.base16_gui02 or '#3b4252' }) end)

require('ibl').setup {
  indent = { char = '│' },
  scope = {
    enabled = true,
    highlight = rainbow,
    -- No horizontal underline on the first/last line of the scope — a
    -- whole-line underline can't line up with vertical brackets. The scope is
    -- shown by the vertical │ guide instead (colored above), which sits flush
    -- with the bracket structure.
    show_start = false,
    show_end = false,
  },
}

-- vim: ts=2 sts=2 sw=2 et
