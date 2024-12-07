return {
  'catppuccin/nvim',
  enabled = false,
  lazy = false,
  name = 'catppuccin',
  priority = 1000,
  opts = {
    integrations = {
      aerial = true,
      alpha = true,
      cmp = true,
      dashboard = true,
      flash = true,
      gitsigns = {
        enabled = true,
        signs = {
          add = { fg = '#94E2D5' },    -- teal equivalent
          change = { fg = '#CBA6F7' }, -- purple equivalent
          delete = { fg = '#F38BA8' }, -- red equivalent
        },
      },
      headlines = true,
      illuminate = true,
      indent_blankline = { enabled = true },
      leap = true,
      lsp_trouble = true,
      mason = true,
      markdown = true,
      mini = true,
      native_lsp = {
        enabled = true,
        underlines = {
          errors = { 'undercurl' },
          hints = { 'undercurl' },
          warnings = { 'undercurl' },
          information = { 'undercurl' },
        },
      },
      navic = { enabled = true, custom_bg = 'lualine' },
      neotest = true,
      neotree = true,
      noice = true,
      notify = true,
      semantic_tokens = true,
      telescope = true,
      treesitter = true,
      treesitter_context = true,
      which_key = true,
    },
    custom_highlights = function(colors)
      return {
        BufferlineInactive = { bg = colors.mantle },
        BufferlineActiveSeparator = { bg = colors.base, fg = colors.mantle },
        BufferlineInactiveSeparator = { bg = colors.mantle, fg = colors.crust },

        NeoTreeFileNameOpened = { fg = colors.peach },

        GitSignsCurrentLineBlame = { fg = colors.surface1 },

        -- Tabs
        TabActive = { bg = colors.base },
        TabActiveSeparator = { bg = colors.base, fg = colors.crust },
        TabInactive = { bg = colors.mantle },
        TabInactiveSeparator = { bg = colors.mantle, fg = colors.crust },

        SidebarTabActive = { bg = colors.mantle },
        SidebarTabActiveSeparator = { bg = colors.mantle, fg = colors.crust },
        SidebarTabInactive = { bg = colors.crust, fg = colors.surface1 },
        SidebarTabInactiveSeparator = { bg = colors.crust, fg = colors.crust },

        StatusLine = { bg = colors.crust, fg = colors.text },
        StatusLineComment = { bg = colors.crust, fg = colors.surface1 },

        LineNrAbove = { fg = colors.surface1 },
        LineNr = { fg = colors.surface2 },
        LineNrBelow = { fg = colors.surface1 },

        MsgArea = { bg = colors.crust },

        SpellBad = { undercurl = true, sp = colors.red },

        -- Telescope
        TelescopeNormal = { bg = colors.mantle, fg = colors.text },
        TelescopeBorder = { bg = colors.mantle, fg = colors.mantle },
        TelescopePromptNormal = { bg = colors.surface0 },
        TelescopePromptBorder = { bg = colors.surface0, fg = colors.surface0 },
        TelescopePromptTitle = { bg = colors.base, fg = colors.text },
        TelescopePreviewTitle = { bg = colors.mantle, fg = colors.mantle },
        TelescopeResultsTitle = { bg = colors.mantle, fg = colors.mantle },

        -- Indent
        IblIndent = { fg = colors.surface0 },
        IblScope = { fg = colors.surface1 },

        -- Floaterm
        Floaterm = { bg = colors.surface0 },
        FloatermBorder = { bg = colors.surface0, fg = colors.surface0 },

        -- Copilot
        CopilotSuggestion = { fg = colors.surface1 },

        -- NvimTree
        NvimTreeIndentMarker = { fg = colors.surface0 },
        NvimTreeOpenedFile = { fg = colors.text, bold = true },
        NvimTreeNormal = { bg = colors.crust },
        NvimTreeNormalNC = { bg = colors.crust },
        NvimTreeWinSeparator = { fg = colors.crust, bg = colors.crust },
      }
    end,
  },
  config = function(plugin, opts)
    require('catppuccin').setup(opts)

    vim.cmd('colorscheme catppuccin-mocha')
  end,
}
