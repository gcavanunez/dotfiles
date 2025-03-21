return {
  'github/copilot.vim',
  config = function()
    vim.g.copilot_no_tab_map = true
    vim.g.copilot_assume_mapped = true
    vim.keymap.set('i', '<C-j>', 'copilot#Accept("\\<CR>")', {
      expr = true,
      replace_keycodes = false,
      silent = true,
    })
    --
    -- vim.keymap.set('i', '<C-j>', '<cmd>lua require("copilot").accept()<CR>', {
    --   silent = true,
    -- })

    -- " vim.cmd([[
    -- "   imap <silent><script><expr> <M-CR> copilot#Accept("\\<CR>")
    -- "   let g:copilot_no_tab_map = v:true
    -- " ]])
  end,
}
