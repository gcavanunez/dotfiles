return {
  'saghen/blink.cmp',
  -- optional: provides snippets for the snippet source
  dependencies = { 'rafamadriz/friendly-snippets', 'onsails/lspkind-nvim' },

  -- use a release tag to download pre-built binaries
  version = '*',
  -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
  -- build = 'cargo build --release',
  -- If you use nix, you can build from source using latest nightly rust with:
  -- build = 'nix run .#build-plugin',

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
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
        auto_show = true,
        draw = {
          components = {
            kind_icon = {
              text = function(ctx)
                return require('lspkind').symbolic(ctx.kind, {
                  mode = 'symbol',
                  preset = 'codicons',
                })
              end,
            },
          },
        },
      },
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
      default = { 'lsp', 'path', 'snippets', 'buffer' },
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
