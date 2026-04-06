-- Custom statusline (replaces windline.nvim)
-- Self-contained airline-style statusline using only modern Neovim APIs.
-- Source: lua/user/statusline.lua
return {
  dir = vim.fn.stdpath('config'),
  name = 'user-statusline',
  lazy = false,
  config = function()
    require('user.statusline').setup()
  end,
}
