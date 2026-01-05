-- return {
--   'nvim-treesitter/nvim-treesitter',
--   lazy = false,
--   -- event = 'VeryLazy',
--   -- build = function()
--   --   require('nvim-treesitter.install').update({ with_sync = true })
--   -- end
--   build = ':TSUpdate',
--   branch = 'main',
--   dependencies = {
--     -- { 'nvim-treesitter/playground', cmd = 'TSPlaygroundToggle' },
--     {
--       'nvim-treesitter/nvim-treesitter-context',
--     },
--     {
--       'nvim-treesitter/nvim-treesitter-textobjects',
--       branch = 'main',
--       opts = {
--         select = {
--           lookahead = true,
--           keymaps = {
--             ['if'] = '@function.inner',
--             ['af'] = '@function.outer',
--             ['ic'] = '@class.inner',
--             ['ac'] = '@class.outer',
--             ['il'] = '@loop.inner',
--             ['al'] = '@loop.outer',
--             ['ia'] = '@parameter.inner',
--             ['aa'] = '@parameter.outer',
--           },
--         },
--       },
--     },
--   },
--   main = 'nvim-treesitter.configs',
--   opts = {
--     ensure_installed = {
--       'arduino',
--       'bash',
--       'comment',
--       'css',
--       'diff',
--       'dockerfile',
--       'git_config',
--       'git_rebase',
--       'gitattributes',
--       'gitcommit',
--       'gitignore',
--       'go',
--       'html',
--       'http',
--       'ini',
--       'javascript',
--       'json',
--       'jsonc',
--       'lua',
--       'make',
--       'markdown',
--       'passwd',
--       'php',
--       'php_only',
--       'blade',
--       'phpdoc',
--       'python',
--       'regex',
--       'ruby',
--       'rust',
--       'sql',
--       'svelte',
--       'typescript',
--       'vim',
--       'vue',
--       'xml',
--       'yaml',
--       'eex',
--       'elixir',
--     },
--     auto_install = true,
--     highlight = {
--       enable = true,
--     },
--     indent = {
--       enable = true,
--       disable = { 'yaml' },
--     },
--     -- context_commentstring = {
--     --   enable = true,
--     -- },
--     rainbow = {
--       enable = true,
--     },
--     textobjects = {
--       select = {
--         enable = true,
--         lookahead = true,
--         keymaps = {
--           ['if'] = '@function.inner',
--           ['af'] = '@function.outer',
--           ['ia'] = '@parameter.inner',
--           ['aa'] = '@parameter.outer',
--         },
--       },
--     },

--     incremental_selection = {
--       enable = true,
--       keymaps = {
--         node_incremental = 'v',
--         node_decremental = 'V',
--       },
--     },
--   },
--   -- config = function(_, opts)
--   --   require('nvim-treesitter.config').setup(opts)

--   --   vim.filetype.add({
--   --     extension = {
--   --       mdx = 'mdx',
--   --     },
--   --   })

--   --   vim.treesitter.language.register('markdown', 'mdx')
--   -- end,
-- }
--
--
local function map(modes, lhs, rhs, opts)
  local defaults = {
    silent = true,
    noremap = true,
    expr = false,
    -- unique = true,
  }
  vim.keymap.set(modes, lhs, rhs, vim.tbl_extend('force', defaults, opts or {}))
end

local parsers = {
  'bash',
  -- 'sh',
  'blade',
  'c',
  'comment',
  'cpp',
  'css',
  'csv',
  -- 'dap_repl',
  'devicetree',
  'diff',
  'dockerfile',
  'ebnf',
  'git_config',
  'git_rebase',
  'gitattributes',
  'gitcommit',
  'gitignore',
  'jsx',
  'tsx',
  'go',
  'html',
  'http',
  'ini',
  'javascript',
  'json',
  'json5',
  -- 'jsonc',
  'jsdoc',
  -- 'latex',
  'lua',
  'luadoc',
  'make',
  'markdown',
  'markdown_inline',
  'mermaid',
  'ocaml',
  'passwd',
  'php',
  'php_only',
  'phpdoc',
  'python',
  -- 'typescriptreact',
  'query',
  'regex',
  'ruby',
  'rust',
  'sql',
  'svelte',
  'typescript',
  'ssh_config',
  'toml',
  'twig',
  'vim',
  'vue',
  'vimdoc',
  'xml',
  'yaml',
  'eex',
  'elixir',
}

-- local ft_map = {
--   ['typescript.tsx'] = 'tsx',
--   ecma = 'javascript',
--   javascriptreact = 'javascript',
--   jsx = 'javascript',
--   ts = 'typescript',
--   typescriptreact = 'tsx',
-- }
---@type LazySpec
return {
  {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    branch = 'main',
    build = ':TSUpdate',
    -- opts = { cmd = { 'TSUpdate', 'TSInstall', 'TSUpdateSync', 'TSUninstall' } },

    config = function(_, opts)
      local nts = require('nvim-treesitter')

      vim.api.nvim_create_autocmd('FileType', {
        pattern = parsers,
        callback = function()
          vim.treesitter.start()
          vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })

      vim.api.nvim_create_autocmd('User', {
        pattern = 'TSUpdate',
        callback = function()
          local configs = require('nvim-treesitter.parsers')

          -- configs.blade.install_info = {
          --   path = '~/sources/treesitter/tree-sitter-blade',
          --   generate = true,
          --   generate_from_json = true,
          -- }

          -- configs.phpdoc.install_info = {
          --   path = '~/sources/treesitter/tree-sitter-phpdoc',
          --   generate = true,
          --   generate_from_json = true,
          -- }

          -- configs.php.install_info = {
          --   path = '~/sources/treesitter/tree-sitter-php',
          --   location = 'php',
          --   generate = true,
          --   generate_from_json = true,
          -- }

          -- configs.php_only.install_info = {
          --   path = '~/sources/treesitter/tree-sitter-php',
          --   location = 'php_only',
          --   generate = true,
          --   generate_from_json = true,
          -- }
        end,
      })

      nts.setup(opts)
      nts.install(parsers)

      -- for filetype, lang in pairs(ft_map) do
      --   vim.treesitter.language.register(lang, filetype)
      -- end
      map('n', '<leader>it', vim.treesitter.inspect_tree)
      map('n', '<leader>i', vim.show_pos)

      -- require('nvim-treesitter.configs').setup()
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    opts = {},
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',

    config = function()
      -- https://github.com/petobens/dotfiles/blob/8ba33101280423cd41cb86bf7f7641d4c2100da1/nvim/lua/plugin-config/treesitter_config.lua#L2
      require('nvim-treesitter-textobjects').setup({
        select = {
          lookahead = true,
          -- selection_modes = {
          --   ['@parameter.outer'] = 'v', -- charwise
          --   ['@function.outer'] = 'V',  -- linewise
          --   ['@class.outer'] = '<c-v>', -- blockwise
          -- },
          -- keymaps = {
          --   ['if'] = '@function.inner',
          --   ['af'] = '@function.outer',
          --   ['ic'] = '@class.inner',
          --   ['ac'] = '@class.outer',
          --   ['il'] = '@loop.inner',
          --   ['al'] = '@loop.outer',
          --   ['ia'] = '@parameter.inner',
          --   ['aa'] = '@parameter.outer',
          -- },
        },
      })

      local tom = function(m, q, d)
        vim.keymap.set({ 'x', 'o' }, m, function()
          require('nvim-treesitter-textobjects.select').select_textobject(q, 'textobjects')
        end, { desc = d })
      end

      tom('af', '@function.outer', 'select function [outer]')
      tom('if', '@function.inner', 'select function [inner]')

      -- tom('ac', '@class.outer', 'select class [outer]')
      -- tom('ic', '@class.inner', 'select class [inner]')

      -- tom('al', '@loop.outer', 'select loop [outer]')
      -- tom('il', '@loop.inner', 'select loop [inner]')

      -- tom('ab', '@block.outer', 'select block [outer]')
      -- tom('ib', '@block.inner', 'select block [inner]')
      -- Incremental selection
      -- https://www.reddit.com/r/neovim/comments/1kuj9xm/has_anyone_successfully_switched_to_the_new/
      _G.selected_nodes = {}

      local function get_node_at_cursor()
        local node = vim.treesitter.get_node()
        if not node then
          return nil
        end
        return node
      end

      local function select_node(node)
        if not node then
          return
        end
        local start_row, start_col, end_row, end_col = node:range()
        vim.fn.setpos("'<", { 0, start_row + 1, start_col + 1, 0 })
        vim.fn.setpos("'>", { 0, end_row + 1, end_col, 0 })
        vim.cmd('normal! gv')
      end

      vim.keymap.set({ 'n' }, '<leader>v', function()
        _G.selected_nodes = {}

        local current_node = get_node_at_cursor()
        if not current_node then
          return
        end

        table.insert(_G.selected_nodes, current_node)
        select_node(current_node)
      end, { desc = 'Select treesitter node' })

      vim.keymap.set('x', 'v', function()
        if #_G.selected_nodes == 0 then
          return
        end

        local current_node = _G.selected_nodes[#_G.selected_nodes]

        if not current_node then
          return
        end

        local parent = current_node:parent()
        if parent then
          table.insert(_G.selected_nodes, parent)
          select_node(parent)
        end
      end, { desc = 'Increment selection' })

      vim.keymap.set('x', 'V', function()
        table.remove(_G.selected_nodes)
        local current_node = _G.selected_nodes[#_G.selected_nodes]
        if current_node then
          select_node(current_node)
        end
      end, { desc = 'Decrement selection' })
    end,
  },

  {
    'folke/ts-comments.nvim',
    opts = {
      lang = {
        vue = {
          '<!-- %s -->',
          script_element = '// %s',
        },
        javascript = {
          '// %s', -- default commentstring when no treesitter node matches
          '/* %s */',
          call_expression = '// %s', -- specific commentstring for call_expression
          jsx_attribute = '// %s',
          jsx_element = '{/* %s */}',
          jsx_fragment = '{/* %s */}',
          spread_element = '// %s',
          statement_block = '// %s',
        },
      },
    },
    event = 'VeryLazy',
    enabled = true,
    -- enabled = vim.fn.has('nvim-0.10.0') == 1,
    --
  },
}
