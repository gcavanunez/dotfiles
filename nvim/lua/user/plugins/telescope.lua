return {
  'nvim-telescope/telescope.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'ThePrimeagen/harpoon',
    'ahmedkhalf/project.nvim',
    'nvim-tree/nvim-web-devicons',
    'nvim-telescope/telescope-live-grep-args.nvim',
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
  },
  keys = {
    {
      '<leader>f',
      function()
        require('telescope.builtin').find_files()
      end,
    },
    {
      '<leader>F',
      function()
        require('telescope.builtin').find_files({ no_ignore = true, prompt_title = 'All Files' })
      end,
    },
    {
      '<leader>b',
      function()
        require('telescope.builtin').buffers()
      end,
    },
    {
      '<leader>g',
      function()
        require('telescope').extensions.live_grep_args.live_grep_args()
      end,
    },
    {
      '<leader>h',
      function()
        require('telescope.builtin').oldfiles()
      end,
    },
    {
      '<leader>ss',
      function()
        require('telescope.builtin').lsp_document_symbols()
      end,
    },
    {
      '<leader>sS',
      function()
        require('telescope.builtin').lsp_dynamic_workspace_symbols()
      end,
    },
    {
      '<leader>G',
      function()
        require('telescope.builtin').git_status()
      end,
    },
  },
  config = function()
    local actions = require('telescope.actions')

    local previewers = require('telescope.previewers')

    local focus_preview = function(prompt_bufnr)
      local action_state = require('telescope.actions.state')
      local actions = require('telescope.actions')
      local picker = action_state.get_current_picker(prompt_bufnr)
      local prompt_win = picker.prompt_win
      local previewer = picker.previewer
      local winid = previewer.state.winid
      local bufnr = previewer.state.bufnr
      vim.keymap.set('n', '<Tab>', function()
        vim.cmd(string.format('noautocmd lua vim.api.nvim_set_current_win(%s)', prompt_win))
      end, { buffer = bufnr })
      vim.keymap.set('n', 'q', function()
        actions.close(prompt_bufnr)
      end, { buffer = bufnr })
      vim.cmd(string.format('noautocmd lua vim.api.nvim_set_current_win(%s)', winid))
      -- api.nvim_set_current_win(winid)
    end
    -- local delta = previewers.new_termopen_previewer {
    --   get_command = function(entry)
    --     -- this is for status
    --     -- You can get the AM things in entry.status. So we are displaying file if entry.status == '??' or 'A '
    --     -- just do an if and return a different command
    --     if entry.status == '??' or 'A ' then
    --       return {'git', '-c', 'core.pager=delta', '-c', 'delta.side-by-side=false', 'diff', entry.value}
    --     end

    --     -- note we can't use pipes
    --     -- this command is for git_commits and git_bcommits
    --     return {'git', '-c', 'core.pager=delta', '-c', 'delta.side-by-side=false', 'diff', entry.value .. '^!'}

    --   end
    -- }
    -- local delta = previewers.new_termopen_previewer {
    --   get_command = function(entry)
    --     return { 'git', '-c', 'core.pager=delta', '-c', 'delta.side-by-side=false', 'diff', entry.value .. '^!', '--', entry.current_file }
    --   end
    -- }

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
          n = {
            ['<C-p>'] = require('telescope.actions.layout').toggle_preview,
            ['<Tab>'] = focus_preview,
          },
          i = {
            ['<C-p>'] = require('telescope.actions.layout').toggle_preview,
            ['<esc>'] = actions.close,
            ['<S-Down>'] = actions.cycle_history_next,
            ['<S-Up>'] = actions.cycle_history_prev,
            -- ['<S-Tab>'] = focus_preview,
          },
        },
        set_env = {
          LESS = '',
          DELTA_PAGER = 'less',
        },
        file_ignore_patterns = { '.git/' },
      },
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = 'smart_case',
        },
        live_grep_args = {
          mappings = {
            i = {
              ['<C-k>'] = require('telescope-live-grep-args.actions').quote_prompt(),
              ['<C-i>'] = require('telescope-live-grep-args.actions').quote_prompt({ postfix = ' --iglob ' }),
            },
          },
        },
      },
      pickers = {
        find_files = {
          hidden = true,
          previewer = false,
          layout_config = {
            width = 100,
          },
        },
        buffers = {
          previewer = true,
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
          -- previewer = delta,
          layout_config = {
            -- vertical = { width = 0.5 }
            width = 140,
          },
        },
      },
      -- builtin = {
      --   git_status = {
      --     previewer = delta
      --   },
      -- }
    })

    require('telescope').load_extension('fzf')
    require('telescope').load_extension('harpoon')

    local live_grep_args_shortcuts = require('telescope-live-grep-args.shortcuts')
    vim.keymap.set('v', '<leader>H', live_grep_args_shortcuts.grep_visual_selection)

    local mark = require('harpoon.mark')
    local ui = require('harpoon.ui')

    vim.keymap.set('n', '<leader>a', mark.add_file)
    vim.keymap.set('n', '<C-e>', ui.toggle_quick_menu, { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>1', function()
      ui.nav_file(1)
    end, { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>2', function()
      ui.nav_file(2)
    end, { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>3', function()
      ui.nav_file(3)
    end, { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>4', function()
      ui.nav_file(4)
    end, { noremap = true, silent = true })
    vim.keymap.set('n', '<leader><Tab>', function()
      ui.nav_next()
    end)
    vim.keymap.set('n', '<leader><S-Tab>', function()
      ui.nav_prev()
    end)

    -- vim.keymap.set("n","<leader>hc", function() mark.clear_all() end)
    -- vim.api.nvim_create_autocmd({ 'User' }, {
    --   pattern = 'TelescopePreviewerLoaded',
    --   callback = function(data)
    --     local winid = data.data.winid
    --     vim.wo[winid].number = true
    --   end,
    -- })
    require('telescope').load_extension('projects')
    require('telescope').load_extension('noice')
    require('project_nvim').setup()
  end,
}
