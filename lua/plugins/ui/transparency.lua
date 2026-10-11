local base16 = function(index, fallback)
  local m = vim.g['base16_gui' .. index]
  return m ~= nil and m or fallback
end

local function hex_to_rgb(hex)
  if not hex then
    return nil
  end
  hex = hex:gsub('#', '')
  if #hex < 6 then
    return nil
  end
  return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
end

local function transparent()
  local r, g, b = hex_to_rgb(base16('00', nil))
  if not r then
    return
  end

  for group, hl in pairs(vim.api.nvim_get_hl(0, {})) do
    if hl.bg == bit.lshift(r, 16) + bit.lshift(g, 8) + b then
      vim.api.nvim_set_hl(0, group, { bg = 'none' })
    end
  end

  vim.api.nvim_set_hl(0, 'Normal', { fg = base16('05', nil), bg = 'none' })
  vim.api.nvim_set_hl(0, 'NormalNC', { fg = base16('05', nil), bg = 'none' })
end

vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('Transparency', { clear = true }),
  desc = 'Keep the editor background transparent across colorscheme reloads.',
  callback = transparent,
})

vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
transparent()
