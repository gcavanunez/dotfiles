return {
  'famiu/bufdelete.nvim',
  config = function()
    vim.keymap.set('n', '<Leader>q', ':Bdelete<CR>')
    vim.keymap.set('n', '<Leader>Q', '<cmd>:bd<cr>')

    -- map("n", "<leader>bD", "<cmd>:bd<cr>", { desc = "Delete Buffer and Window" })
  end,
}
