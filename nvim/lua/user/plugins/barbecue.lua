return {
  'utilyre/barbecue.nvim',
  -- event = 'BufRead',
  name = "barbecue",
  version = "*",

  dependencies = {
    "SmiteshP/nvim-navic",
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    attach_navic = false,
    theme = 'tokyonight',
    show_modified = true,
  },
  -- config = function ()
  --   -- local breadcrumbs = function(client, bufnr)
  --   --   if client.name == "volar" then
  --   --       return
  --   --   end
  --   require("barbecue").setup({
  --     attach_navic = false,
  --     create_autocmd = false, -- prevent barbecue from updating itself automatically
  --   })
  -- end,
}
