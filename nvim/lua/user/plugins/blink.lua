return {
  'saghen/blink.cmp',
  -- optional: provides snippets for the snippet source
  dependencies = {
    'rafamadriz/friendly-snippets',
    { 'saghen/blink.compat', version = '*' },
    'onsails/lspkind-nvim',
    {
      'xzbdmw/colorful-menu.nvim',
      opts = {},
    },
    {
      'L3MON4D3/LuaSnip',
      version = 'v2.*',
      config = function()
        require('luasnip/loaders/from_vscode').lazy_load()
        require('luasnip/loaders/from_snipmate').lazy_load()
      end,
    },
  },

  -- use a release tag to download pre-built binaries
  version = '*',
  -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
  -- build = 'cargo build --release',
  -- If you use nix, you can build from source using latest nightly rust with:
  -- build = 'nix run .#build-plugin',

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {

    snippets = { preset = 'luasnip' },
    -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
    -- 'super-tab' for mappings similar to vscode (tab to accept)
    -- 'enter' for enter to accept
    -- 'none' for no mappings
    --
    -- All presets have the following mappings:
    -- C-space: Open menu or open docs if already open
    -- C-n/C-p or Up/Down: Select next/previous item
    -- C-e: Hide menu
    -- C-k: Toggle signature help (if signature.enabled = true)
    --
    -- See :h blink-cmp-config-keymap for defining your own keymap
    keymap = {
      preset = 'enter',
      ['<Tab>'] = {
        function(cmp)
          if cmp.is_ghost_text_visible() and not cmp.is_menu_visible() then
            return cmp.accept()
          end
        end,
        'show_and_insert',
        'select_next',
      },
      -- ['<Tab>'] = {
      --   'snippet_forward',
      --   function() -- sidekick next edit suggestion
      --     return require('sidekick').nes_jump_or_apply()
      --   end,
      --   function() -- if you are using Neovim's native inline completions
      --     return vim.lsp.inline_completion.get()
      --   end,
      --   'fallback',
      -- },
      ['<S-Tab>'] = { 'show_and_insert', 'select_prev' },
    },
    -- cmdline = {
    --   keymap = {
    --     -- recommended, as the default keymap will only show and select the next item
    --     ['<Tab>'] = { 'show', 'accept' },
    --   },
    --   completion = { menu = { auto_show = true } },
    -- },
    appearance = {
      -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      nerd_font_variant = 'mono',
    },
    completion = {
      menu = {
        -- border = 'rounded',
        draw = {
          -- Components to render, grouped by column
          -- padding = { 0, 1 },
          columns = { { 'kind_icon' }, { 'label', gap = 1 }, { 'source_name' } },
          components = {
            kind_icon = {
              text = function(ctx)
                local icon = ctx.kind_icon

                -- if require('blink.cmp.sources.lsp.hacks.tailwind').get_hex_color(ctx.item) then
                --   return Icons.lsp.kinds.tailwind_color
                -- end

                if ctx.source_name == 'Path' then
                  local dev_icon, _ = require('nvim-web-devicons').get_icon(ctx.label)
                  if dev_icon then
                    icon = dev_icon
                  end
                elseif ctx.source_name == 'Blade-nav' then
                  icon = ''
                else
                  icon = require('lspkind').symbolic(ctx.kind, { mode = 'symbol' })
                end

                return icon .. ctx.icon_gap
              end,
              highlight = function(ctx)
                local hl = 'BlinkCmpKind' .. ctx.kind

                if require('blink.cmp.sources.lsp.hacks.tailwind').get_hex_color(ctx.item) then
                  hl = ctx.kind_hl
                end

                if ctx.source_name == 'Path' then
                  local dev_icon, dev_hl = require('nvim-web-devicons').get_icon(ctx.label)
                  if dev_icon then
                    hl = dev_hl
                  end
                elseif ctx.source_name == 'Blade-nav' then
                  hl = 'BlinkCmpKindBladeNav'
                end
                return hl
              end,
            },
            label = {
              text = function(ctx)
                return require('colorful-menu').blink_components_text(ctx)
              end,
              highlight = function(ctx)
                return require('colorful-menu').blink_components_highlight(ctx)
              end,
            },
          },
          -- Use treesitter to highlight the label text for the given list of sources
          treesitter = { 'lsp' },
        },
        max_height = 20,
      },
      -- menu = {
      --   auto_show = true,
      --   draw = {
      --     components = {
      --       kind_icon = {
      --         text = function(ctx)
      --           return require('lspkind').symbolic(ctx.kind, {
      --             mode = 'symbol',
      --             preset = 'codicons',
      --           })
      --         end,
      --       },
      --     },
      --   },
      -- },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 0,
      },
      list = { selection = { preselect = false, auto_insert = true } },
    },
    signature = {
      enabled = true,
    },
    -- completion = { menu = { draw = { columns = { { 'label', 'label_description', gap = 1 }, { 'kind_icon', 'kind' } } } } },

    -- Default list of enabled providers defined so that you can extend it
    -- elsewhere in your config, without redefining it, due to `opts_extend`
    sources = {
      default = {
        'lsp',
        'path',
        'snippets',
        'buffer',
        -- 'blade-nav',
        'laravel',
      },
      providers = {
        laravel = {
          name = 'laravel',
          module = 'blink.compat.source',
          score_offset = 95, -- show at a higher priority than lsp
        },
        -- ['blade-nav'] = {
        --   module = 'blade-nav.blink',
        --   opts = {
        --     close_tag_on_complete = false, -- default: true,
        --     include_routes = false,
        --   },
        --
        --   score_offset = 100,
        -- },
      },
      -- providers = {
      --   blade_nav = {
      --     name = 'blade-nav',
      --     module = 'blink.compat.source',
      --   },
      -- },
    },

    -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
    -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
    -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
    --
    -- See the fuzzy documentation for more information
    fuzzy = { implementation = 'prefer_rust_with_warning' },
  },
  opts_extend = { 'sources.default' },
}
