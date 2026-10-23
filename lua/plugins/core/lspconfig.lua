local function gh(repo) return 'https://github.com/' .. repo end

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
-- Neovim. This is where `mason` and related plugins come into play.
--
-- If you're wondering about lsp vs treesitter, you can check out the wonderfully
-- and elegantly composed help section, `:help lsp-vs-treesitter`

-- Useful status updates for LSP.
vim.pack.add { gh 'j-hui/fidget.nvim' }
require('fidget').setup {}

--  This function gets run when an LSP attaches to a particular buffer.
--    That is to say, every time a new file is opened that is associated with
--    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
--    function will be executed to configure the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
  callback = function(event)
    -- NOTE: Remember that Lua is a real programming language, and as such it is possible
    -- to define small helper and utility functions so you don't have to repeat yourself.
    --
    -- In this case, we create a function that lets us more easily define mappings specific
    -- for LSP related items. It sets the mode, buffer and description for us each time.
    local map = function(keys, func, desc, mode)
      mode = mode or 'n'
      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    -- Rename the variable under your cursor.
    --  Most Language Servers support renaming across files, etc.
    map('grn', vim.lsp.buf.rename, '[R]e[n]ame')

    -- Execute a code action, usually your cursor needs to be on top of an error
    -- or a suggestion from your LSP for this to activate.
    map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })

    -- WARN: This is not Goto Definition, this is Goto Declaration.
    --  For example, in C this would take you to the header.
    map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

    -- The following two autocommands are used to highlight references of the
    -- word under your cursor when your cursor rests there for a little while.
    --    See `:help CursorHold` for information about when this is executed
    --
    -- When you move your cursor, the highlights will be cleared (the second autocommand).
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method('textDocument/documentHighlight', event.buf) then
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

    -- The following code creates a keymap to toggle inlay hints in your
    -- code, if the language server you are using supports them
    --
    -- This may be unwanted, since they displace some of your code
    if client and client:supports_method('textDocument/inlayHint', event.buf) then
      vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
      map('<leader>th', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end, '[T]oggle Inlay [H]ints')
    end
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
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
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

-- [[ Java / jdtls ]]
vim.pack.add {
  'https://github.com/mfussenegger/nvim-jdtls',
}

-- Fill these in with wherever you cloned/built java-debug and vscode-java-test.
-- java-debug:       https://github.com/microsoft/java-debug  (build with ./mvnw clean install)
-- vscode-java-test: https://github.com/microsoft/vscode-java-test (build with npm install && npm run build-plugin)
local JAVA_DEBUG_JAR = vim.fn.glob(vim.fn.expand '~/dev/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar')
local JAVA_TEST_JARS = vim.split(vim.fn.glob(vim.fn.expand '~/dev/vscode-java-test/server/*.jar', true), '\n')

local function setup_jdtls()
  local jdtls = require 'jdtls'

  local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
  local workspace_dir = vim.fn.stdpath 'data' .. '/jdtls-workspace/' .. project_name

  local bundles = { JAVA_DEBUG_JAR }
  vim.list_extend(bundles, JAVA_TEST_JARS)

  local config = {
    cmd = { 'jdtls', '-data', workspace_dir },

    root_dir = require('jdtls.setup').find_root { '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' },

    settings = {
      java = {
        eclipse = { downloadSources = true },
        configuration = { updateBuildConfiguration = 'interactive' },
        maven = { downloadSources = true },
        implementationsCodeLens = { enabled = true },
        referencesCodeLens = { enabled = true },
        references = { includeDecompiledSources = true },
        format = { enabled = true },
        signatureHelp = { enabled = true },
        completion = {
          favoriteStaticMembers = {
            'org.junit.Assert.*', 'org.junit.jupiter.api.Assertions.*',
            'org.mockito.Mockito.*',
          },
        },
        inlayHints = { parameterNames = { enabled = 'all' } },
      },
    },

    init_options = {
      bundles = bundles,
      extendedClientCapabilities = jdtls.extendedClientCapabilities,
    },

    on_attach = function(_, bufnr)
      -- Registers the Java debug adapter with the nvim-dap instance
      -- that debug.lua already configured (dap.continue / <F5> etc. just work).
      jdtls.setup_dap { hotcodereplace = 'auto' }
      require('jdtls.dap').setup_dap_main_class_configs()

      local opts = { buffer = bufnr }
      vim.keymap.set('n', '<leader>co', jdtls.organize_imports, opts)
      vim.keymap.set('n', 'crv', jdtls.extract_variable, opts)
      vim.keymap.set('v', 'crv', function() jdtls.extract_variable(true) end, opts)
      vim.keymap.set('n', 'crc', jdtls.extract_constant, opts)
      vim.keymap.set('v', 'crc', function() jdtls.extract_constant(true) end, opts)
      vim.keymap.set('v', 'crm', function() jdtls.extract_method(true) end, opts)
      vim.keymap.set('n', '<leader>df', jdtls.test_class, opts)
      vim.keymap.set('n', '<leader>dn', jdtls.test_nearest_method, opts)
      vim.keymap.set('n', '<leader>tu', jdtls.update_project_config, opts)
    end,
  }

  jdtls.start_or_attach(config)
end

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'java',
  group = vim.api.nvim_create_augroup('kickstart-jdtls', { clear = true }),
  callback = setup_jdtls,
})

vim.pack.add {
  gh 'neovim/nvim-lspconfig',
}

for name, config in pairs(servers) do
  vim.lsp.config(name, config)
  vim.lsp.enable(name)
end
-- vim: ts=2 sts=2 sw=2 et
