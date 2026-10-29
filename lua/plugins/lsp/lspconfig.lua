local gh = require('util').gh

-- [[ LSP Configuration ]]
-- Brief aside: **What is LSP?**
--
-- LSP is an initialism you've probably heard, but might not understand what it is.
--
-- LSP stands for Language Server Protocol. It's a protocol that helps editors
-- and language tooling communicate in a standardized fashion.
--
-- In general, you have a "server" which is some tool built to understand a particular
-- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
-- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
-- processes that communicate with some "client" - in this case, Neovim!
--
-- LSP provides Neovim with features like:
--  - Go to definition
--  - Find references
--  - Autocompletion
--  - Symbol Search
--  - and more!
--
-- Thus, Language Servers are external tools that must be installed separately from
-- Neovim. On this machine they are installed via Nix and expected on $PATH.
--
-- If you're wondering about lsp vs treesitter, you can check out the wonderfully
-- and elegantly composed help section, `:help lsp-vs-treesitter`

-- Useful status updates for LSP.
vim.pack.add { gh 'j-hui/fidget.nvim' }
require('fidget').setup {}

-- LSP Attach: buffer-local settings (highlighting, inlay hints)
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client then return end

    -- Document highlighting
    if client:supports_method('textDocument/documentHighlight', event.buf) then
      local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })
      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
        end,
      })
    end

    -- Inlay hints
    if client:supports_method('textDocument/inlayHint', event.buf) then vim.lsp.inlay_hint.enable(true, { bufnr = event.buf }) end
  end,
})

local nixd_dirs = {
  vim.fs.normalize '~/Projects/chimera',
  vim.fs.normalize '~/Projects/chimera-pkgs',
}

-- Returns the matching nixd project dir for a buffer, or nil
local function nixd_dir_for(bufnr)
  local fname = vim.fs.normalize(vim.api.nvim_buf_get_name(bufnr)) .. '/'
  for _, dir in ipairs(nixd_dirs) do
    if vim.startswith(fname, dir .. '/') then return dir end
  end
end

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They must be on $PATH (Nix).
--  See `:help lsp-config` for information about keys and how to configure
---@type table<string, vim.lsp.Config>
local servers = {
  bashls = {},
  clangd = {},
  basedpyright = {},

  yamlls = {},
  -- rust_analyzer = {},
  --
  -- Some languages (like typescript) have entire language plugins that can be useful:
  --    https://github.com/pmizio/typescript-tools.nvim
  --
  -- But for many setups, the LSP (`ts_ls`) will work just fine
  -- ts_ls = {},

  stylua = {}, -- Used to format Lua code

  nil_ls = {
    root_dir = function(bufnr, on_dir)
      if nixd_dir_for(bufnr) then return end -- nixd territory, don't attach
      on_dir(vim.fs.root(bufnr, { 'flake.nix', '.git' }) or vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)))
    end,
    settings = {
      ['nil'] = {
        formatting = { command = { 'alejandra', '--quiet', '-' } },
      },
    },
  },

  nixd = {
    root_dir = function(bufnr, on_dir)
      local dir = nixd_dir_for(bufnr)
      if dir then on_dir(dir) end
    end,
    settings = {
      nixd = {
        nixpkgs = {
          expr = 'import (builtins.getFlake "/home/oxce5/Projects/chimera").inputs.nixpkgs { }',
        },
        options = {
          nixos = {
            expr = '(builtins.getFlake "/home/oxce5/Projects/chimera").nixosConfigurations.overlord.options',
          },
          home_manager = {
            expr = '(builtins.getFlake "/home/oxce5/Projects/chimera").homeConfigurations."oxce5@overlord".options',
          },
        },
      },
    },
  },

  -- Special Lua Config, as recommended by neovim help docs
  lua_ls = {
    on_init = function(client)
      client.server_capabilities.documentFormattingProvider = false -- Disable formatting (formatting is done by stylua)

      if client.workspace_folders then
        local path = client.workspace_folders[1].name
        if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
      end

      client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
        runtime = {
          version = 'LuaJIT',
          path = { 'lua/?.lua', 'lua/?/init.lua' },
        },
        workspace = {
          checkThirdParty = false,
          -- NOTE: this is a lot slower and will cause issues when working on your own configuration.
          --  See https://github.com/neovim/nvim-lspconfig/issues/3189
          library = vim.tbl_extend('force', vim.api.nvim_get_runtime_file('', true), {
            '${3rd}/luv/library',
            '${3rd}/busted/library',
          }),
        },
      })
    end,
    ---@type lspconfig.settings.lua_ls
    settings = {
      Lua = {
        format = { enable = false }, -- Disable formatting (formatting is done by stylua)
      },
    },
  },
}

-- Languages that manage their own LSP lifecycle (e.g. Java via nvim-jdtls)
-- live in sibling files in this directory, not here.

vim.pack.add {
  gh 'neovim/nvim-lspconfig',
}

for name, config in pairs(servers) do
  vim.lsp.config(name, config)
  vim.lsp.enable(name)
end
-- vim: ts=2 sts=2 sw=2 et
