return {
  'voldikss/vim-floaterm',
  keys = {
    { '<leader>P', '<cmd>FloatermToggle<CR>' },
    { '<leader>P', '<C-\\><C-n><cmd>FloatermToggle<CR>', mode = 't' },
  },
  cmd = { 'FloatermToggle' },
  init = function()
    vim.g.floaterm_width = 0.8
    vim.g.floaterm_height = 0.8
  end,
}
