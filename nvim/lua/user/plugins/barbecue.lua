return {
  'utilyre/barbecue.nvim',
  event = 'BufRead',
  dependencies = {
    "SmiteshP/nvim-navic",
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    theme = 'tokyonight',
  },
  config = function()
    -- local breadcrumbs = function(client, bufnr)
    --   if client.name == "volar" then
    --       return
    --   end
  end
}
