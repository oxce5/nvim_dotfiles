-- R (R.nvim) - self-managed R session + language server
--
-- R.nvim doesn't fit the standard `vim.lsp.config` / `vim.lsp.enable` flow: it
-- drives an interactive R session through Neovim's built-in terminal (or tmux)
-- and runs its own language server (`rnvimserver`), building its companion R
-- package (`nvimcom`) on first use. Standard servers live in lspconfig.lua.
--
-- Dependencies (expected on $PATH via Nix): `R`, a C compiler, `make`.
-- Optional R packages: `languageserver` (richer autocompletion), `colorout`.

local gh = require('util').gh

vim.pack.add { gh 'R-nvim/R.nvim' }

---@type RConfigUserOpts
require('r').setup {
  R_args = { '--quiet', '--no-save' },
  min_editor_width = 72,
  rconsole_width = 78,

  -- R.nvim registers its own <localleader>r* maps (send chunk/region/line,
  -- object browser, help, ...) — see `:RMapsDesc` once inside an R buffer.
  hook = {
    on_filetype = function()
      -- Opt-in convenience: send the current line / selection to R with <Enter>.
      -- Uncomment if you want it (it overrides <Enter> in r/rmd buffers).
      -- vim.api.nvim_buf_set_keymap(0, 'n', '<Enter>', '<Plug>RDSendLine', {})
      -- vim.api.nvim_buf_set_keymap(0, 'v', '<Enter>', '<Plug>RSendSelection', {})
    end,
  },
}

-- Notes:
--  * The `r` treesitter parser is auto-installed on FileType by
--    plugins/code/treesitter.lua. vim.pack also clones R.nvim's
--    `tree-sitter-rout` submodule, so `.Rout` highlighting works out of the box.
--  * The companion R package (`nvimcom`) and `rnvimserver` binary are compiled
--    lazily on first R session start — `R` and a C compiler must be on $PATH.
--  * To auto-start R when opening an .R file, set in an env-triggered branch:
--      require('r').setup { auto_start = 'on startup', objbr_auto_start = true }

-- vim: ts=2 sts=2 sw=2 et
