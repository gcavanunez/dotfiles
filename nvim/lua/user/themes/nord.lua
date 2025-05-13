return {
  'gbprod/nord.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    require('nord').setup({
      override = {
        -- Git signs
        GitSignsAdd = { fg = '#A3BE8C' },
        GitSignsChange = { fg = '#B48EAD' },
        GitSignsDelete = { fg = '#BF616A' },
        GitSignsCurrentLineBlame = { fg = '#4C566A' },

        -- UI elements
        BufferlineInactive = { bg = '#2E3440' },
        BufferlineActiveSeparator = { bg = '#3B4252', fg = '#232831' },
        BufferlineInactiveSeparator = { bg = '#2E3440', fg = '#232831' },

        NeoTreeFileNameOpened = { fg = '#D08770' },

        -- Tabs
        TabActive = { bg = '#3B4252' },
        TabActiveSeparator = { bg = '#3B4252', fg = '#232831' },
        TabInactive = { bg = '#2E3440' },
        TabInactiveSeparator = { bg = '#2E3440', fg = '#232831' },

        SidebarTabActive = { bg = '#2E3440' },
        SidebarTabActiveSeparator = { bg = '#2E3440', fg = '#232831' },
        SidebarTabInactive = { bg = '#232831', fg = '#4C566A' },
        SidebarTabInactiveSeparator = { bg = '#232831', fg = '#232831' },

        StatusLine = { bg = '#232831', fg = '#D8DEE9' },
        StatusLineComment = { bg = '#232831', fg = '#4C566A' },

        LineNrAbove = { fg = '#4C566A' },
        LineNr = { fg = '#616E88' },
        LineNrBelow = { fg = '#4C566A' },

        MsgArea = { bg = '#232831' },

        SpellBad = { undercurl = true, sp = '#BF616A' },

        -- Telescope
        TelescopeNormal = { bg = '#2E3440', fg = '#D8DEE9' },
        TelescopeBorder = { bg = '#2E3440', fg = '#2E3440' },
        TelescopePromptNormal = { bg = '#3B4252' },
        TelescopePromptBorder = { bg = '#3B4252', fg = '#3B4252' },
        TelescopePromptTitle = { bg = '#3B4252', fg = '#D8DEE9' },
        TelescopePreviewTitle = { bg = '#2E3440', fg = '#2E3440' },
        TelescopeResultsTitle = { bg = '#2E3440', fg = '#2E3440' },

        -- Indent
        IblIndent = { fg = '#3B4252' },
        IblScope = { fg = '#4C566A' },

        -- Floaterm
        Floaterm = { bg = '#3B4252' },
        FloatermBorder = { bg = '#3B4252', fg = '#3B4252' },

        -- Copilot
        CopilotSuggestion = { fg = '#4C566A' },

        -- NvimTree
        NvimTreeIndentMarker = { fg = '#3B4252' },
        NvimTreeOpenedFile = { fg = '#D8DEE9', bold = true },
        NvimTreeNormal = { bg = '#232831' },
        NvimTreeNormalNC = { bg = '#232831' },
        NvimTreeWinSeparator = { fg = '#232831', bg = '#232831' },
      },
    })
    -- vim.cmd('colorscheme nord')
  end,
}
