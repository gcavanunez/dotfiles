return {
  'famiu/bufdelete.nvim',
  config = function()
    -- vim.keymap.set('n', '<Leader>q', '<cmd>Bdelete<CR>')
    -- -- Delete Buffer and Window
    -- vim.keymap.set('n', '<Leader>Q', '<cmd>bd<cr>')
    -- vim.keymap.set('n', '<leader>Q', ':bufdo bdelete<CR>')

    -- Close current buffer without closing window
    vim.keymap.set('n', '<Leader>qq', '<cmd>Bdelete<CR>')

    -- Close current buffer and window
    vim.keymap.set('n', '<Leader>QQ', '<cmd>bd<cr>')

    -- Close all buffers
    vim.keymap.set('n', '<leader>qa', '<cmd>bufdo bdelete<CR>')

    -- map("n", "<leader>bD", "<cmd>:bd<cr>", { desc = "Delete Buffer and Window" })
  end,
}
