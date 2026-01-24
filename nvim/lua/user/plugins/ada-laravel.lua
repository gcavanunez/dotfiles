return {
  'adalessa/laravel.nvim',
  -- dir = '~/nvim-plugins/laravel.nvim',
  dependencies = {
    'tpope/vim-dotenv',
    'MunifTanjim/nui.nvim',
    'nvim-lua/plenary.nvim',
    'nvim-neotest/nvim-nio',
  },
  ft = { 'php', 'blade' },
  event = {
    'BufEnter composer.json',
  },
  cmd = { 'Laravel' },
  keys = {
    -- lua Laravel.commands.run("tinker:open")
    -- lua Laravel.commands.run("env:configure:open")
    {
      '<leader>ll',
      function()
        Laravel.pickers.laravel()
      end,
      desc = 'Laravel: Open Laravel Picker',
    },
    {
      '<leader>la',
      function()
        Laravel.pickers.artisan()
      end,
      desc = 'Laravel: Open Artisan Picker',
    },
    {
      '<leader>lt',
      function()
        Laravel.commands.run('actions')
      end,
      desc = 'Laravel: Open Actions Picker',
    },
    {
      '<leader>lr',
      function()
        Laravel.pickers.routes()
      end,
      desc = 'Laravel: Open Routes Picker',
    },
    {
      '<leader>lR',
      function()
        Laravel.pickers.resources()
      end,
      desc = 'Laravel: View related',
    },
    {
      '<leader>lm',
      function()
        Laravel.commands.run('picker:related')
      end,
      desc = 'Laravel: View related',
    },
    {
      '<leader>le',
      function()
        Laravel.commands.run('env:configure:open')
      end,
      desc = 'Laravel: View related',
    },
    {
      '<leader>lp',
      function()
        Laravel.commands.run('command_center')
      end,
      desc = 'Laravel: Open Command Center',
    },
    {
      'gf',
      function()
        local ok, res = pcall(function()
          if Laravel.app('gf').cursorOnResource() then
            return "<cmd>lua Laravel.commands.run('gf')<cr>"
          end
        end)
        if not ok or not res then
          return 'gf'
        end
        return res
      end,
      expr = true,
      noremap = true,
    },
  },

  opts = {
    -- user_providers = {
    --   require('user.plugins.laravel.provider_model_info'),
    -- },
    lsp_server = 'phpactor', -- "phpactor | intelephense"
    features = {
      pickers = {
        provider = 'snacks', -- "snacks | telescope | fzf-lua | ui-select"
      },
    },
  },
}
