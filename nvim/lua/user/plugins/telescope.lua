return {
  'nvim-telescope/telescope.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'ThePrimeagen/harpoon',
    'nvim-tree/nvim-web-devicons',
    'nvim-telescope/telescope-live-grep-args.nvim',
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
  },
  keys = {
    { '<leader>f', function() require('telescope.builtin').find_files() end },
    { '<leader>F', function() require('telescope.builtin').find_files({ no_ignore = true, prompt_title = 'All Files' }) end },
    { '<leader>b', function() require('telescope.builtin').buffers() end },
    { '<leader>g', function() require('telescope').extensions.live_grep_args.live_grep_args() end },
    { '<leader>h', function() require('telescope.builtin').oldfiles() end },
    { '<leader>s', function() require('telescope.builtin').lsp_document_symbols() end },
    { '<leader>G', function() require('telescope.builtin').git_status() end },
  },
  config = function ()
    local actions = require('telescope.actions')

    require('telescope').setup({
      defaults = {
        path_display = { truncate = 1 },
        prompt_prefix = '   ',
        selection_caret = '  ',
        layout_config = {
          prompt_position = 'top',
        },
        preview = {
          timeout = 200,
        },
        sorting_strategy = 'ascending',
        mappings = {
          i = {
            ['<esc>'] = actions.close,
            ['<S-Down>'] = actions.cycle_history_next,
            ['<S-Up>'] = actions.cycle_history_prev,
          },
        },
        file_ignore_patterns = { '.git/' },
      },
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
        live_grep_args = {
          mappings = {
            i = {
              ["<C-k>"] = require("telescope-live-grep-args.actions").quote_prompt(),
              ["<C-i>"] = require("telescope-live-grep-args.actions").quote_prompt({ postfix = " --iglob " }),
            },
          },
        },
      },
      pickers = {
        find_files = {
          hidden = true,
        },
        buffers = {
          previewer = false,
          layout_config = {
            width = 80,
          },
        },
        oldfiles = {
          prompt_title = 'History',
          cwd_only = true,
        },
        lsp_references = {
          previewer = false,
        },
        lsp_definitions = {
          previewer = false,
        },
        lsp_document_symbols = {
          symbol_width = 55,
        },
        git_status = {
          previewer = true
        }
      },
    })

    require('telescope').load_extension('fzf')
    require('telescope').load_extension('harpoon')

    local live_grep_args_shortcuts = require("telescope-live-grep-args.shortcuts")
    vim.keymap.set("v", "<leader>H", live_grep_args_shortcuts.grep_visual_selection)

    local mark = require("harpoon.mark")
    local ui = require("harpoon.ui")

    vim.keymap.set("n", "<leader>a", mark.add_file)
    vim.keymap.set("n", "<C-p>", ui.toggle_quick_menu)
    vim.keymap.set("n","<leader><Tab>", function() ui.nav_next() end)
    vim.keymap.set("n","<leader><S-Tab>", function() ui.nav_prev() end)
    vim.keymap.set("n","<leader>hc", function() mark.clear_all() end)
  end,
}
