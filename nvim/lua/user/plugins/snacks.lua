---@module 'snacks'
return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    dashboard = { enabled = false },
    explorer = { enabled = false },
    indent = {
      enabled = false,
    },
    input = {
      -- enabled = true,
    },
    notifier = {
      enabled = false,
      -- timeout = 3000,
    },
    picker = {
      enabled = true,
      actions = {
        cycle_preview = function(picker)
          local layout_config = vim.deepcopy(picker.resolved_layout)

          if layout_config.preview == 'main' or not picker.preview.win:valid() then
            return
          end

          local function find_preview(root) ---@param root snacks.layout.Box|snacks.layout.Win
            if root.win == 'preview' then
              return root
            end
            if #root then
              for _, w in ipairs(root) do
                local preview = find_preview(w)
                if preview then
                  return preview
                end
              end
            end
            return nil
          end

          local preview = find_preview(layout_config.layout)

          if not preview then
            return
          end

          local eval = function(s)
            return type(s) == 'function' and s(preview.win) or s
          end
          --- @type number?, number?
          local width, height = eval(preview.width), eval(preview.height)

          if not width and not height then
            return
          end

          local cycle_sizes = { 0.1, 0.9 }
          local size_prop, size

          if height then
            size_prop, size = 'height', height
          else
            size_prop, size = 'width', width
          end

          picker.init_size = picker.init_size or size ---@diagnostic disable-line: inject-field
          table.insert(cycle_sizes, picker.init_size)
          table.sort(cycle_sizes)

          for i, s in ipairs(cycle_sizes) do
            if size == s then
              local smaller = cycle_sizes[i - 1] or cycle_sizes[#cycle_sizes]
              preview[size_prop] = smaller
              break
            end
          end

          for i, h in ipairs(layout_config.hidden) do
            if h == 'preview' then
              table.remove(layout_config.hidden, i)
            end
          end

          picker:set_layout(layout_config)
        end,
      },
      layouts = {
        ivy = {
          layout = {
            box = 'vertical',
            backdrop = 60,
            row = -1,
            width = 0,
            height = 0.7,
            border = 'top',
            title = ' {title} {live} {flags}',
            title_pos = 'left',
            { win = 'input', height = 1, border = 'bottom' },
            {
              box = 'horizontal',
              { win = 'list', border = 'none' },
              { win = 'preview', title = '{preview}', width = 0.65, border = 'left' },
            },
          },
        },
      },
      sources = {
        -- https://github.com/folke/snacks.nvim/issues/871
        projects = {
          dev = {
            '~/_www',
            -- https://x.com/mitchellh/status/1941865776803467509
          },
        },
      },
      win = {
        -- input window
        input = {
          keys = {
            -- https://github.com/folke/snacks.nvim/blob/bc0630e43be5699bb94dadc302c0d21615421d93/docs/picker.md?plain=1#L200
            ['<a-o>'] = { 'toggle_modified', mode = { 'i', 'n' } },

            ['<a-c>'] = { 'cycle_preview', mode = { 'i', 'n' } },
          },
        },
      },
    },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = false },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    styles = {
      notification = {
        -- wo = { wrap = true } -- Wrap notifications
      },
    },
  },
  keys = {
    -- Top Pickers & Explorer
    -- {
    --   '<leader><space>',
    --   function()
    --     Snacks.picker.smart()
    --   end,
    --   desc = 'Smart Find Files',
    -- },
    {
      '<leader>b',
      function()
        Snacks.picker.buffers({

          -- on_show = function()
          --   vim.cmd.stopinsert()
          -- end,
          finder = 'buffers',
          format = 'buffer',
          hidden = false,
          unloaded = true,
          current = true,
          sort_lastused = true,
          layout = 'ivy',
          win = {
            input = {
              keys = {
                ['d'] = 'bufdelete',
              },
            },
            list = {
              keys = {
                ['d'] = 'bufdelete',
              },
            },
          },
        })
      end,
      desc = 'Buffers',
    },
    -- {
    --   '<leader>/',
    --   function()
    --     Snacks.picker.grep()
    --   end,
    --   desc = 'Grep',
    -- },
    {
      '<leader>:',
      function()
        Snacks.picker.command_history()
      end,
      desc = 'Command History',
    },
    -- {
    --   '<leader>n',
    --   function()
    --     Snacks.picker.notifications()
    --   end,
    --   desc = 'Notification History',
    -- },
    -- {
    --   '<leader>e',
    --   function()
    --     Snacks.explorer()
    --   end,
    --   desc = 'File Explorer',
    -- },
    -- find
    -- {
    --   '<leader>fb',
    --   function()
    --     Snacks.picker.buffers()
    --   end,
    --   desc = 'Buffers',
    -- },
    -- {
    --   '<leader>fc',
    --   function()
    --     Snacks.picker.files({ cwd = vim.fn.stdpath('config') })
    --   end,
    --   desc = 'Find Config File',
    -- },
    {
      '<leader>F',
      function()
        Snacks.picker.files({
          layout = 'ivy',
          ignored = true,
        })
      end,
      desc = 'All Files',
    },
    {
      '<leader>F',
      function()
        Snacks.picker.files({
          layout = 'ivy',
          ignored = true,
          on_show = function(picker)
            vim.api.nvim_input(picker:word())
            -- picker.input.win.opts.actions.insert_cword.action()
          end,
        })
      end,
      desc = 'All Files',
      mode = { 'x' },
    },
    {
      '<leader>f',
      function()
        Snacks.picker.files({
          layout = 'ivy',
        })
      end,
      desc = 'Files',
    },
    {
      '<leader>f',
      function()
        Snacks.picker.files({
          layout = 'ivy',
          on_show = function(picker)
            vim.api.nvim_input(picker:word())
            -- picker.input.win.opts.actions.insert_cword.action()
          end,
        })
      end,
      desc = 'Files',
      mode = { 'x' },
    },
    {
      '<leader>GG',
      function()
        Snacks.picker.git_files()
      end,
      desc = 'Find Git Files',
    },
    {
      '<leader>gp',
      function()
        Snacks.picker.projects()
      end,
      desc = 'Projects',
    },
    {
      '<leader>h',
      function()
        Snacks.picker.recent({
          filter = { cwd = true },
        })
      end,
      desc = 'Recent',
    },
    -- git
    {
      '<leader>gb',
      function()
        Snacks.picker.git_branches()
      end,
      desc = 'Git Branches',
    },
    {
      '<leader>gl',
      function()
        Snacks.picker.git_log({
          previewers = { git = { native = true } },
        })
      end,
      desc = 'Git Log',
    },
    {
      '<leader>gL',
      function()
        Snacks.picker.git_log_line({
          previewers = { git = { native = true } },
        })
      end,
      desc = 'Git Log Line',
    },
    {
      '<leader>gs',
      function()
        Snacks.picker.git_status({
          layout = 'ivy',
          previewers = { git = { native = true } },
        })
      end,
      desc = 'Git Status',
    },
    {
      '<leader>gS',
      function()
        Snacks.picker.git_stash()
      end,
      desc = 'Git Stash',
    },
    {
      '<leader>gd',
      function()
        Snacks.picker.git_diff({
          layout = 'ivy',
          previewers = { git = { native = true }, diff = { native = true } },
          -- base = 'trunk',
        })
      end,
      desc = 'Git Diff (Hunks)',
    },
    {
      '<leader>gF',
      function()
        Snacks.picker.git_log_file({
          previewers = { git = { native = true } },
          layout = 'ivy',
        })
      end,
      desc = 'Git Log File',
    },
    -- Grep
    {
      '<leader>sb',
      function()
        Snacks.picker.lines()
      end,
      desc = 'Buffer Lines',
    },
    {
      '<leader>sB',
      function()
        Snacks.picker.grep_buffers()
      end,
      desc = 'Grep Open Buffers',
    },
    {
      '<leader>gg',
      function()
        Snacks.picker.grep({
          layout = 'ivy',
        })
      end,
      desc = 'Grep',
    },
    {
      '<leader>gg',
      function()
        Snacks.picker.grep_word({
          layout = 'ivy',
          live = true,
        })
      end,
      desc = 'Grep',
      mode = { 'x' },
    },
    {
      '<leader>gG',
      function()
        Snacks.picker.grep({
          layout = 'ivy',
          ignored = true,
        })
      end,
      desc = 'Grep',
    },
    {
      '<leader>gG',
      function()
        Snacks.picker.grep_word({
          layout = 'ivy',
          ignored = true,
          live = true,
        })
      end,
      desc = 'Grep',
      mode = { 'x' },
    },
    {
      '<leader>sO',
      function()
        Snacks.picker.grep({
          cwd = '~/My Drive/_cloudBrain/',
          title = 'Obsidian vault',
        })
      end,
      desc = 'Grep',
    },
    {
      '<leader>H',
      function()
        Snacks.picker.grep_word({
          layout = 'ivy',
        })
      end,
      desc = 'Visual selection or word',
      mode = { 'n', 'x' },
    },
    -- search
    {
      '<leader>s"',
      function()
        Snacks.picker.registers()
      end,
      desc = 'Registers',
    },
    {
      '<leader>s/',
      function()
        Snacks.picker.search_history()
      end,
      desc = 'Search History',
    },
    {
      '<leader>sa',
      function()
        Snacks.picker.autocmds()
      end,
      desc = 'Autocmds',
    },
    {
      '<leader>sb',
      function()
        Snacks.picker.lines()
      end,
      desc = 'Buffer Lines',
    },
    {
      '<leader>sc',
      function()
        Snacks.picker.command_history()
      end,
      desc = 'Command History',
    },
    {
      '<leader>sC',
      function()
        Snacks.picker.commands()
      end,
      desc = 'Commands',
    },
    {
      '<leader>sd',
      function()
        Snacks.picker.diagnostics()
      end,
      desc = 'Diagnostics',
    },
    {
      '<leader>sD',
      function()
        Snacks.picker.diagnostics_buffer()
      end,
      desc = 'Buffer Diagnostics',
    },
    {
      '<leader>sh',
      function()
        Snacks.picker.help()
      end,
      desc = 'Help Pages',
    },
    {
      '<leader>sH',
      function()
        Snacks.picker.highlights()
      end,
      desc = 'Highlights',
    },
    {
      '<leader>si',
      function()
        Snacks.picker.icons({
          layout = 'ivy',
        })
      end,
      desc = 'Icons',
    },
    {
      '<leader>sj',
      function()
        Snacks.picker.jumps()
      end,
      desc = 'Jumps',
    },
    {
      '<leader>sk',
      function()
        Snacks.picker.keymaps()
      end,
      desc = 'Keymaps',
    },
    {
      '<leader>sl',
      function()
        Snacks.picker.loclist()
      end,
      desc = 'Location List',
    },
    {
      '<leader>sm',
      function()
        Snacks.picker.marks()
      end,
      desc = 'Marks',
    },
    {
      '<leader>sM',
      function()
        Snacks.picker.man()
      end,
      desc = 'Man Pages',
    },
    {
      '<leader>sp',
      function()
        Snacks.picker.lazy()
      end,
      desc = 'Search for Plugin Spec',
    },
    {
      '<leader>sq',
      function()
        Snacks.picker.qflist()
      end,
      desc = 'Quickfix List',
    },
    {
      '<leader>sR',
      function()
        Snacks.picker.resume()
      end,
      desc = 'Resume',
    },
    {
      '<leader>su',
      function()
        Snacks.picker.undo({
          layout = 'ivy',
          previewers = { diff = { native = true } },
        })
      end,
      desc = 'Undo History',
    },
    {
      '<leader>uC',
      function()
        Snacks.picker.colorschemes()
      end,
      desc = 'Colorschemes',
    },
    -- LSP
    {
      'gd',
      function()
        Snacks.picker.lsp_definitions({
          filter = {
            filter = function(item)
              return not vim.endswith(item.file, '_model_helpers.php') -- for adalessa/laravel.nvim
            end,
          },
          layout = 'ivy',
        })
      end,
      desc = 'Goto Definition',
    },
    -- {
    --   'gD',
    --   function()
    --     Snacks.picker.lsp_declarations()
    --   end,
    --   desc = 'Goto Declaration',
    -- },
    {
      'gr',
      function()
        Snacks.picker.lsp_references({
          layout = 'ivy',
        })
      end,
      nowait = true,
      desc = 'References',
    },
    {
      'gi',
      function()
        Snacks.picker.lsp_implementations({
          layout = 'ivy',
        })
      end,
      desc = 'Goto Implementation',
    },
    -- {
    --   'gy',
    --   function()
    --     Snacks.picker.lsp_type_definitions()
    --   end,
    --   desc = 'Goto T[y]pe Definition',
    -- },
    {
      '<leader>ss',
      function()
        Snacks.picker.lsp_symbols()
      end,
      desc = 'LSP Symbols',
    },
    {
      '<leader>sS',
      function()
        Snacks.picker.lsp_workspace_symbols()
      end,
      desc = 'LSP Workspace Symbols',
    },
    -- Other
    {
      '<leader>z',
      function()
        Snacks.zen()
      end,
      desc = 'Toggle Zen Mode',
    },
    {
      '<leader>ZZ',
      function()
        Snacks.zen.zoom()
      end,
      desc = 'Toggle Zoom',
    },
    {
      '<leader>Zz',
      function()
        Snacks.picker.zoxide()
      end,
      desc = 'Toggle Zoom',
    },
    {
      '<leader>.',
      function()
        Snacks.scratch()
      end,
      desc = 'Toggle Scratch Buffer',
    },
    {
      '<leader>S',
      function()
        Snacks.scratch.select()
      end,
      desc = 'Select Scratch Buffer',
    },
    -- {
    --   '<leader>n',
    --   function()
    --     Snacks.notifier.show_history()
    --   end,
    --   desc = 'Notification History',
    -- },
    -- {
    --   '<leader>bd',
    --   function()
    --     Snacks.bufdelete()
    --   end,
    --   desc = 'Delete Buffer',
    -- },
    -- {
    --   '<leader>cR',
    --   function()
    --     Snacks.rename.rename_file()
    --   end,
    --   desc = 'Rename File',
    -- },
    {
      '<leader>gB',
      function()
        Snacks.gitbrowse()
      end,
      desc = 'Git Browse',
      mode = { 'n', 'v' },
    },
    {
      '<leader>lg',
      function()
        Snacks.lazygit()
      end,
      desc = 'Lazygit',
    },
    {
      '<leader>lG',
      function()
        ---@param opts? snacks.lazygit.Config
        Snacks.lazygit.log_file()
      end,
      desc = 'Lazygit',
    },
    -- {
    --   '<leader>un',
    --   function()
    --     Snacks.notifier.hide()
    --   end,
    --   desc = 'Dismiss All Notifications',
    -- },
    {
      '<c-/>',
      function()
        Snacks.terminal()
      end,
      desc = 'Toggle Terminal',
    },
    -- {
    --   '<c-_>',
    --   function()
    --     Snacks.terminal()
    --   end,
    --   desc = 'which_key_ignore',
    -- },
    {
      ']]',
      function()
        Snacks.words.jump(vim.v.count1)
      end,
      desc = 'Next Reference',
      mode = { 'n', 't' },
    },
    {
      '[[',
      function()
        Snacks.words.jump(-vim.v.count1)
      end,
      desc = 'Prev Reference',
      mode = { 'n', 't' },
    },
    {
      '<leader>N',
      desc = 'Neovim News',
      function()
        Snacks.win({
          file = vim.api.nvim_get_runtime_file('doc/news.txt', false)[1],
          width = 0.6,
          height = 0.6,
          wo = {
            spell = false,
            wrap = false,
            signcolumn = 'yes',
            statuscolumn = ' ',
            conceallevel = 3,
          },
        })
      end,
    },
  },
  init = function()
    vim.api.nvim_create_autocmd('User', {
      pattern = 'VeryLazy',
      callback = function()
        -- Setup some globals for debugging (lazy-loaded)
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end
        _G.bt = function()
          Snacks.debug.backtrace()
        end
        vim.print = _G.dd -- Override print to use snacks for `:=` command

        -- Create some toggle mappings
        Snacks.toggle.option('spell', { name = 'Spelling' }):map('<leader>us')
        Snacks.toggle.option('wrap', { name = 'Wrap' }):map('<leader>uw')
        Snacks.toggle.option('relativenumber', { name = 'Relative Number' }):map('<leader>uL')
        Snacks.toggle.diagnostics():map('<leader>ud')
        Snacks.toggle.line_number():map('<leader>ul')
        Snacks.toggle.option('conceallevel', { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map('<leader>uc')
        Snacks.toggle.treesitter():map('<leader>uT')
        Snacks.toggle.option('background', { off = 'light', on = 'dark', name = 'Dark Background' }):map('<leader>ub')
        Snacks.toggle.inlay_hints():map('<leader>uh')
        Snacks.toggle.indent():map('<leader>ug')
        Snacks.toggle.dim():map('<leader>uD')
      end,
    })
  end,
}
