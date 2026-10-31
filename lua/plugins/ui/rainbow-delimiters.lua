-- rainbow-delimiters.nvim - alternating colours for matched brackets/parens
--
-- Draws {} () [] in cycling colours (via treesitter) so matching pairs are
-- easy to tell apart. The same palette colours the indent-blankline scope
-- guide (see ui/indent-line.lua).
--
-- Source lives on GitLab (GitHub is only a mirror).
--
-- This integration registers hooks on indent-blankline (ibl.hooks), so ibl is
-- declared here too and must be set up afterwards in ui/indent-line.lua.
vim.pack.add {
  'https://gitlab.com/HiPhish/rainbow-delimiters.nvim',
  'https://github.com/lukas-reineke/indent-blankline.nvim',
}

-- The ordered set of highlight groups both rainbow-delimiters and the
-- indent-blankline scope guide cycle through.
--
-- These are fixed saturated hues (not derived from the matugen palette): the
-- Material base16 accents are desaturated pastels that also collide across
-- indices, which would collapse the rainbow into a few near-white tones. A
-- rainbow only works if the colours are distinct and vivid, so they are pinned.
local highlight = { 'RainbowRed', 'RainbowYellow', 'RainbowBlue', 'RainbowOrange', 'RainbowGreen', 'RainbowViolet', 'RainbowCyan' }

local rainbow = {
  { group = 'RainbowRed', hex = '#E06C75' },
  { group = 'RainbowYellow', hex = '#E5C07B' },
  { group = 'RainbowBlue', hex = '#61AFEF' },
  { group = 'RainbowOrange', hex = '#D19A66' },
  { group = 'RainbowGreen', hex = '#98C379' },
  { group = 'RainbowViolet', hex = '#C678DD' },
  { group = 'RainbowCyan', hex = '#56B6C2' },
}

local hooks = require 'ibl.hooks'

-- Define the rainbow groups right before ibl renders so they survive any
-- colorscheme change. This hook re-runs on ColorScheme (which matugen.setup()
-- emits), re-asserting the colours on initial load and on every SIGUSR1 reload.
hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
  for _, r in ipairs(rainbow) do
    vim.api.nvim_set_hl(0, r.group, { fg = r.hex })
  end
end)

-- rainbow-delimiters reads its config from this global (set before it loads).
vim.g.rainbow_delimiters = { highlight = highlight }

-- Let indent-blankline's scope guide adopt the colour of the delimiter extmark
-- at the cursor, so the scope line matches the surrounding brackets.
hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)

-- vim: ts=2 sts=2 sw=2 et
