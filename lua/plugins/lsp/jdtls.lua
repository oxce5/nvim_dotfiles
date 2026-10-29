-- Java (jdtls) - self-managed LSP
--
-- jdtls doesn't fit the standard `vim.lsp.config` / `vim.lsp.enable` flow:
-- it's started imperatively via `nvim-jdtls` on FileType, brings its own
-- workspace/workspace-dir handling, and wires itself into nvim-dap.
-- Standard servers live in lspconfig.lua.

local gh = require('util').gh

vim.pack.add { gh 'mfussenegger/nvim-jdtls' }

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
            'org.junit.Assert.*',
            'org.junit.jupiter.api.Assertions.*',
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
      -- that code/debug.lua already configured (dap.continue / <F5> etc. just work).
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
  group = vim.api.nvim_create_augroup('jdtls', { clear = true }),
  callback = setup_jdtls,
})

-- vim: ts=2 sts=2 sw=2 et
