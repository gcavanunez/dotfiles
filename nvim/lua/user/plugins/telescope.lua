return {
  'nvim-telescope/telescope.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'debugloop/telescope-undo.nvim',
    -- 'ahmedkhalf/project.nvim', <- Rebuild myself
    'nvim-tree/nvim-web-devicons',
    'nvim-telescope/telescope-live-grep-args.nvim',
    'nvim-telescope/telescope-ui-select.nvim',
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
  },
  keys = {
    {
      '<leader>f',
      function()
        require('telescope.builtin').find_files({})
        -- require('telescope.builtin').find_files({
        --   default_text = vim.fn.expand('<cword>'),
        -- })
      end,
    },
    {
      '<leader>F',
      function()
        require('telescope.builtin').find_files({ no_ignore = true, prompt_title = 'All Files' })
      end,
    },
    -- {
    --   '<leader>b',
    --   function()
    --     require('telescope.builtin').buffers()
    --   end,
    -- },
    {
      '<leader>gg',
      function()
        require('telescope').extensions.live_grep_args.live_grep_args({
          -- prompt_title = 'Grep Project',
          --     vimgrep_arguments = {
          --       "rg",
          --       "--hidden",
          --       "-L",
          --       "--color=never",
          --       "--sort=path",
          --       "--no-heading",
          --       "--with-filename",
          --       "--line-number",
          --       "--column",
          --       "--smart-case",
          --     }
        })
      end,
    },
    {
      '<leader>gG',
      function()
        require('telescope').extensions.live_grep_args.live_grep_args({
          prompt_title = 'Grep All Files',
          vimgrep_arguments = {
            'rg',
            '--hidden',
            '--no-ignore',
            '-L',
            '--color=never',
            '--sort=path',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
            '--smart-case',
          },
        })
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
    -- {
    --   '<leader>GG',
    --   function()
    --     require('telescope.builtin').git_status()
    --   end,
    -- },
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
            ['<C-l>'] = require('telescope.actions.layout').toggle_preview,
            ['<Tab>'] = focus_preview,
          },
          i = {
            ['<C-l>'] = require('telescope.actions.layout').toggle_preview,
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
          case_mode = 'ignore_case',
        },
        live_grep_args = {
          mappings = {
            i = {
              ['<C-k>'] = require('telescope-live-grep-args.actions').quote_prompt(),
              ['<C-i>'] = require('telescope-live-grep-args.actions').quote_prompt({ postfix = ' --iglob ' }),
            },
          },
        },
        ['ui-select'] = {
          require('telescope.themes').get_dropdown(),
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

    local live_grep_args_shortcuts = require('telescope-live-grep-args.shortcuts')
    vim.keymap.set('v', '<leader>sw', live_grep_args_shortcuts.grep_visual_selection)

    -- https://github.com/rafi/vim-config/blob/814f312d92e97282913f4c3ef5f09712840b5604/lua/rafi/util/edit.lua#L10
    local get_visual_selection = function()
      -- this will exit visual mode
      -- use 'gv' to reselect the text
      local _, csrow, cscol, cerow, cecol
      local mode = vim.fn.mode()
      local is_visual = vim.tbl_contains({ 'v', 'V', '\22' }, mode)
      if is_visual then
        -- if we are in visual mode use the live position
        _, csrow, cscol, _ = unpack(vim.fn.getpos('.') or { 0, 0, 0, 0 })
        _, cerow, cecol, _ = unpack(vim.fn.getpos('v') or { 0, 0, 0, 0 })
        if mode == 'V' then
          -- visual line doesn't provide columns
          cscol, cecol = 0, 999
        end
        -- exit visual mode
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', true)
      else
        -- otherwise, use the last known visual position
        _, csrow, cscol, _ = unpack(vim.fn.getpos("'<") or { 0, 0, 0, 0 })
        _, cerow, cecol, _ = unpack(vim.fn.getpos("'>") or { 0, 0, 0, 0 })
      end
      -- swap vars if needed
      if cerow < csrow then
        csrow, cerow = cerow, csrow
      end
      if cecol < cscol then
        cscol, cecol = cecol, cscol
      end
      local lines = vim.fn.getline(csrow, cerow)
      -- local n = cerow-csrow+1
      local n = #lines
      if n <= 0 or type(lines) ~= 'table' then
        return ''
      end
      lines[n] = string.sub(lines[n], 1, cecol)
      lines[1] = string.sub(lines[1], cscol)
      return table.concat(lines, '\n')
    end

    vim.keymap.set('v', '<leader>F', function()
      require('telescope.builtin').find_files({
        default_text = get_visual_selection(),
      })
    end)

    require('telescope').load_extension('undo')
    -- require('telescope').load_extension('projects')
    require('telescope').load_extension('noice')
    require('telescope').load_extension('ui-select')
    -- require('project_nvim').setup()
  end,
}
