vim.pack.add {
  { src = 'https://github.com/folke/noice.nvim', version = vim.version.range '*' },
  'https://github.com/MunifTanjim/nui.nvim',
}

local function base(index, fallback)
  local m = vim.g['base16_gui' .. index]
  return m ~= nil and m or fallback
end

require('noice').setup {
  cmdline = {
    view = 'cmdline_popup',
  },
  messages = {
    view = 'notify',
  },
  popupmenu = {
    backend = 'nui',
    position = 'cursor',
    size = { width = 40, height = 10 },
  },
  presets = {
    bottom_search = true,
    command_palette = true,
    long_message_to_split = true,
    inc_rename = true,
    lsp_doc_border = true,
  },
  -- Reuse the matugen palette so noice matches the rest of the UI.
  -- base16-colorscheme exports it as vim.g.base16_gui00 .. base16_gui0F.
  views = {
    cmdline_popup = {
      border = { style = 'rounded', padding = { 0, 2 } },
      win_options = {
        winhighlight = {
          Normal = 'Normal',
          FloatBorder = 'FloatBorder',
          FloatTitle = 'FloatTitle',
          Border = 'FloatBorder',
        },
      },
    },
    notify = {
      border = { style = 'rounded' },
      win_options = {
        winhighlight = {
          Normal = 'Normal',
          FloatBorder = 'FloatBorder',
          FloatTitle = 'FloatTitle',
          Border = 'FloatBorder',
        },
      },
    },
    cmdline = {
      border = { style = 'none', padding = { 0, 0 } },
    },
  },
}

vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('NoiceMatugen', { clear = true }),
  desc = 'Tint noice with the matugen palette.',
  callback = function()
    local hl = function(group, opts)
      vim.api.nvim_set_hl(0, group, opts)
    end
    local fg, bg = base('05', '#d0d0d0'), base('00', '#202328')
    local border, muted = base('03', '#6c7086'), base('04', '#bbc2cf')

    hl('NoiceCmdlinePopup', { bg = bg, fg = fg })
    hl('NoiceCmdlinePopupBorder', { bg = bg, fg = border })
    hl('NoiceCmdlinePopupTitle', { bg = bg, fg = muted, bold = true })
    hl('NoiceCmdlineIcon', { bg = bg, fg = base('0B', '#98be65') })
    hl('NoiceCmdlinePopupBorderSearch', { bg = bg, fg = base('0D', '#51afef') })
    hl('NoiceCmdlinePopupTitleSearch', { bg = bg, fg = base('0D', '#51afef'), bold = true })
    hl('NoiceCmdlinePopupBorderSearchLeader', { bg = bg, fg = base('0D', '#51afef') })

    hl('NoicePopup', { bg = bg, fg = fg })
    hl('NoicePopupBorder', { bg = bg, fg = border })
    hl('NoicePopupmenu', { bg = base('01', '#2b2e34'), fg = fg })
    hl('NoicePopupmenuBorder', { bg = base('01', '#2b2e34'), fg = border })
    hl('NoicePopupmenuSelected', { bg = base('02', '#3e4451'), fg = base('07', '#ffffff') })
    hl('NoicePopupmenuMatch', { fg = base('0D', '#51afef'), bold = true })
    hl('NoicePopupmenuSelectedMatch', { fg = base('0D', '#51afef'), bold = true })
  end,
})
