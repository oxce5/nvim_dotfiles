local function gh(repo) return 'https://github.com/' .. repo end

-- nvim-lint - async linting
vim.pack.add { gh 'mfussenegger/nvim-lint' }

local lint = require 'lint'

lint.linters_by_ft = {
  python = { 'ruff' },
  java = { 'checkstyle' },
  nix = { 'alejandra' },
  c = { 'clang_tidy' },
  cpp = { 'clang_tidy' },
  lua = { 'selene' },
  sh = { 'shellcheck' },
  bash = { 'shellcheck' },
  fish = { 'fish' },
}

local function list_prepend(dst, src)
  for i = 1, #src do
    table.insert(dst, i, src[i])
  end
end

for name, linter in pairs(lint.linters) do
  if type(linter) == 'table' and type(lint.linters[name]) == 'table' then
    lint.linters[name] = vim.tbl_deep_extend('force', lint.linters[name], linter)
    if type(linter.prepend_args) == 'table' then
      lint.linters[name].args = lint.linters[name].args or {}
      list_prepend(lint.linters[name].args, linter.prepend_args)
    end
  end
end

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
  if #names == 0 then
    vim.list_extend(names, lint.linters_by_ft['_'] or {})
  end
  vim.list_extend(names, lint.linters_by_ft['*'] or {})

  local ctx = { filename = vim.api.nvim_buf_get_name(0) }
  ctx.dirname = vim.fn.fnamemodify(ctx.filename, ':h')
  names = vim.tbl_filter(function(name)
    local l = lint.linters[name]
    if not l then
      vim.notify('Linter not found: ' .. name, vim.log.levels.WARN)
    end
    return l and not (type(l) == 'table' and l.condition and not l.condition(ctx))
  end, names)

  if #names > 0 then
    lint.try_lint(names)
  end
end

vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufReadPost', 'InsertLeave' }, {
  group = vim.api.nvim_create_augroup('nvim-lint', { clear = true }),
  callback = debounce(100, do_lint),
})

vim.keymap.set('n', '<leader>cl', function() do_lint() end, { desc = 'Lint buffer' })
