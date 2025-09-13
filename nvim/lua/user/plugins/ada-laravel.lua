return {
  'adalessa/laravel.nvim',
  -- dir = '~/nvim-plugins/laravel.nvim',
  dependencies = {
    'tpope/vim-dotenv',
    'MunifTanjim/nui.nvim',
    'nvim-lua/plenary.nvim',
    'nvim-neotest/nvim-nio',
  },
  cmd = { 'Laravel' },
  keys = {
    -- lua Laravel.commands.run("tinker:open")
    -- lua Laravel.commands.run("env:configure:open")
    {
      '<leader>la',
      function()
        Laravel.pickers.artisan()
      end,
      desc = 'Laravel: Open Artisan Picker',
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
  },
  event = { 'VeryLazy' },
  opts = {
    user_providers = {
      require('user.plugins.laravel.provider_model_info'),
    },
    lsp_server = 'phpactor', -- "phpactor | intelephense"
    features = {
      pickers = {
        provider = 'snacks', -- "snacks | telescope | fzf-lua | ui-select"
      },
    },
  },
}
