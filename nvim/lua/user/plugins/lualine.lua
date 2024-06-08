return {
  'nvim-lualine/lualine.nvim',
  lazy = false,
  dependencies = {
    'arkav/lualine-lsp-progress',
    'nvim-tree/nvim-web-devicons',
  },
  opts = {
    options = {
      -- section_separators = '',
      -- component_separators = '',
      globalstatus = true,
      theme = "auto"
      -- theme = {
      --   normal = {
      --     a = 'StatusLine',
      --     b = 'StatusLine',
      --     c = 'StatusLine',
      --   },
      -- },
    },
    sections = {
      lualine_a = {
        'mode',
      },
      lualine_b = {
        'branch',
        {
          'diff',
          symbols = { added = ' ', modified = ' ', removed = ' ' },
        },
        function ()
          return '󰅭 ' .. vim.pesc(tostring(#vim.tbl_keys(vim.lsp.buf_get_clients())) or '')
        end,
        { 'diagnostics', sources = { 'nvim_diagnostic' } },
      },
      lualine_c = {
        { 'filename', path = 1 },
        -- require("lualine_require").root_dir(),
        -- {
        --   "diagnostics",
        --   symbols = {
        --     -- error = require("lazy.config").icons..diagnostics.Error,
        --     -- warn = require("lazy.config").icons.diagnostics.Warn,
        --     -- info = require("lazy.config").icons.diagnostics.Info,
        --     -- hint = iconsrequire("lazy.config").icons.diagnostics.Hint,
        --   },
        -- },
        -- { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
        -- { vim.lualine.pretty_path() },
      },
      lualine_x = {
        {
          require("lazy.status").updates,
          cond = require("lazy.status").has_updates,
          color = { fg = "#ff9e64" },
        },
      },
      lualine_y = {
        'filetype',
        'encoding',
        'fileformat',
        '(vim.bo.expandtab and "␠ " or "⇥ ") .. vim.bo.shiftwidth',
      },
      lualine_z = {
        'searchcount',
        'selectioncount',
        'location',
        'progress',
      },
    },
    extensions = { "neo-tree", "lazy" },
  },
}
