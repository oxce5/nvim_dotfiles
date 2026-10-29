local gh = require('util').gh

-- nvim-lint - async linting
-- Linters themselves are expected on $PATH — Nix manages them.
vim.pack.add { gh 'mfussenegger/nvim-lint' }

local lint = require 'lint'

lint.linters_by_ft = {
  python = { 'ruff' },
  java = { 'checkstyle' },
  nix = { 'statix' },
  c = { 'clang_tidy' },
  cpp = { 'clang_tidy' },
  lua = { 'selene' },
  sh = { 'shellcheck' },
  bash = { 'shellcheck' },
  fish = { 'fish' },
}

local function debounce(ms, fn)
  local timer = vim.uv.new_timer()
  return function(...)
    local argv = { ... }
    timer:start(ms, 0, function()
      timer:stop()
      vim.schedule_wrap(fn)(unpack(argv))
    end)
  end
end

local function do_lint()
  local names = lint._resolve_linter_by_ft(vim.bo.filetype)
  names = vim.list_extend({}, names)
  if #names == 0 then vim.list_extend(names, lint.linters_by_ft['_'] or {}) end
  vim.list_extend(names, lint.linters_by_ft['*'] or {})

  local ctx = { filename = vim.api.nvim_buf_get_name(0) }
  ctx.dirname = vim.fn.fnamemodify(ctx.filename, ':h')
  names = vim.tbl_filter(function(name)
    local l = lint.linters[name]
    if not l then vim.notify('Linter not found: ' .. name, vim.log.levels.WARN) end
    return l and not (type(l) == 'table' and l.condition and not l.condition(ctx))
  end, names)

  if #names > 0 then lint.try_lint(names) end
end

vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufReadPost', 'InsertLeave' }, {
  group = vim.api.nvim_create_augroup('nvim-lint', { clear = true }),
  callback = debounce(100, do_lint),
})

-- <leader>c = Code (which-key group)
vim.keymap.set('n', '<leader>cl', function() do_lint() end, { desc = 'Lint Buffer' })

-- vim: ts=2 sts=2 sw=2 et
