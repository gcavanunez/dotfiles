return {
  'gbprod/nord.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    require('nord').setup({
      -- leave this setup function empty for default config
      -- or refer to the configuration section
      -- for configuration options
    })
    -- vim.cmd('colorscheme  nord')
  end,
}
