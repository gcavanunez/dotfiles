return {
  'vim-test/vim-test',
  keys = {
    { '<Leader>tn', '<cmd>TestNearest<CR>' },
    { '<Leader>tf', '<cmd>TestFile<CR>' },
    { '<Leader>ts', '<cmd>TestSuite<CR>' },
    { '<Leader>tl', '<cmd>TestLast<CR>' },
    { '<Leader>tv', '<cmd>TestVisit<CR>' },
  },
  dependencies = { 'voldikss/vim-floaterm' },
  config = function()
    vim.cmd([[let test#strategy = 'neovim']])
    vim.cmd([[let test#neovim#term_position = 'vert']])
    vim.cmd([[let g:test#php#phpunit#executable = "./vendor/bin/phpunit"]])
    vim.cmd([[let g:test#php#pest#executable = "./vendor/bin/pest"]])
  end,
  -- config = function()
  --   vim.cmd([[
  --     " let test#php#phpunit#options = '--colors=always'
  --     " let test#php#pest#options = '--colors=always'

  --     function! FloatermStrategy(cmd)
  --       execute 'silent FloatermSend q'
  --       execute 'silent FloatermKill'
  --       execute 'FloatermNew! '.a:cmd.' |less -X'
  --     endfunction

  --     let g:test#custom_strategies = {'floaterm': function('FloatermStrategy')}
  --     let g:test#strategy = 'floaterm'
  --   ]])
  -- end
}
