return {
  'adalessa/laravel.nvim',
  -- dir = '~/nvim-plugins/laravel.nvim',
  dependencies = {
    'tpope/vim-dotenv',
    'nvim-telescope/telescope.nvim',
    'MunifTanjim/nui.nvim',
    'kevinhwang91/promise-async',
  },
  cmd = { 'Laravel' },
  keys = {
    { '<leader>la', '<cmd>Laravel artisan<cr>' },
    { '<leader>lr', '<cmd>Laravel routes<cr>' },
    { '<leader>lm', '<cmd>Laravel related<cr>' },
  },
  event = { 'VeryLazy' },
  opts = {
    user_providers = {
      require('user.plugins.laravel.provider_model_info'),
    },
  },
  config = true,
}
