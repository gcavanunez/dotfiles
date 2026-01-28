-- From -> https://github.com/chrisgrieser/.config/blob/main/nvim/lua/plugins/noice-and-notification.lua

-- DOCS https://github.com/folke/noice.nvim#-routes
local routes = {
  -- REDIRECT TO POPUP
  -- {
  --   filter = {
  --     min_height = 10,
  --     cond = function(msg)
  --       local title = (msg.opts and msg.opts.title) or ''
  --       return not title:find('tinygit') and not title:find('lazy%.nvim')
  --     end,
  --   },
  --   view = 'popup',
  -- },

  -- output from `:Inspect`, for easier copying
  -- { filter = { event = 'msg_show', find = 'Treesitter.*- @' }, view = 'popup' },

  -----------------------------------------------------------------------------
  -- REDIRECT TO MINI

  -- write/deletion messages
  { filter = { event = 'msg_show', find = '%d+B written$' }, view = 'mini' },
  { filter = { event = 'msg_show', any = { { find = '%d+L, %d+B' }, { find = '; after #%d+' }, { find = '; before #%d+' } } }, view = 'mini' },
  -- { filter = { event = 'msg_show', find = '%d+L, %d+B$' }, view = 'mini' },
  -- { filter = { event = 'msg_show', find = '%-%-No lines in buffer%-%-' }, view = 'mini' },

  -- search
  -- { filter = { event = 'msg_show', find = '^E486: Pattern not found' }, view = 'mini' },

  -- word added to spellfile via `zg`
  -- { filter = { event = 'msg_show', find = '^Word .*%.add$' }, view = 'mini' },

  -- gitsigns.nvim
  -- { filter = { event = 'msg_show', find = 'Hunk %d+ of %d+' }, view = 'mini' },
  -- { filter = { event = 'msg_show', find = 'No hunks' }, view = 'mini' },

  -- :LspRestart
  { filter = { event = 'notify', find = 'Restarting…' }, view = 'mini' },

  -- Intelephense indexing
  { filter = { event = 'notify', find = '^Intelephense:' }, view = 'mini' },

  { filter = { event = 'notify', find = '%[Neo%-tree INFO%]' }, view = 'mini' },
  -----------------------------------------------------------------------------
  -- SKIP

  -- FIX LSP bugs?
  -- { filter = { event = 'msg_show', find = 'lsp_signature? handler RPC' }, skip = true },
  -- stylua: ignore
  -- { filter = { event = "msg_show", find = "^%s*at process.processTicksAndRejections" }, skip = true },

  -- skip test messages
  { filter = { event = 'msg_show', find = '%test' }, view = 'mini' },

  -- code actions
  -- { filter = { event = 'notify', find = 'No code actions available' }, skip = true },

  -- unneeded info on search patterns when pattern not found
  -- { filter = { event = 'msg_show', find = '^[/?].' }, skip = true },

  -- useless notification when closing buffers
  -- {
  --   filter = { event = 'notify', find = '^Client marksman quit with exit code 1 and signal 0.' },
  --   skip = true,
  -- },
}

return {
  'folke/noice.nvim',
  event = 'VeryLazy',
  -- opts = {
  --   -- add any options here
  -- },
  opts = {
    lsp = {
      hover = {
        silent = true,
      },
      --   override = {
      --     ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
      --     ['vim.lsp.util.stylize_markdown'] = true,
      --     ['cmp.entry.get_documentation'] = true,
      --   },
    },
    routes = routes,
    -- routes = {
    --   {
    --     filter = {
    --       event = 'msg_show',
    --       find = '%d+L, %d+B',
    --     },
    --     view = 'mini',
    --   },
    -- },
    presets = {
      bottom_search = true,         -- use a classic bottom cmdline for search
      command_palette = true,       -- position the cmdline and popupmenu together
      long_message_to_split = true, -- long messages will be sent to a split
      inc_rename = true,            -- enables an input dialog for inc-rename.nvim
      lsp_doc_border = true,        -- add a border to hover docs and signature help
    },
  },
  dependencies = {
    -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
    'MunifTanjim/nui.nvim',
    -- OPTIONAL:
    --   `nvim-notify` is only needed, if you want to use the notification view.
    --   If not available, we use `mini` as the fallback
    'rcarriga/nvim-notify',
  },
  keys = {
    -- {
    --   '<S-Enter>',
    --   -- https://github.com/folke/noice.nvim?tab=readme-ov-file#%EF%B8%8F-command-redirection
    --   function()
    --     require('noice').redirect(vim.fn.getcmdline())
    --   end,
    --   mode = 'c',
    --   desc = '󰎟 Redirect Cmdline',
    -- },
  },
  messages = {
    enabled = false, -- enables the Noice messages UI
  },
}
