return {
  'vim-test/vim-test',
  keys = {
    { '<Leader>tn', '<cmd>TestNearest<CR>' },
    { '<Leader>tf', '<cmd>TestFile<CR>' },
    { '<Leader>tS', '<cmd>TestSuite<CR>' },
    { '<Leader>tl', '<cmd>TestLast<CR>' },
    { '<Leader>tv', '<cmd>TestVisit<CR>' },
  },
  dependencies = { 'voldikss/vim-floaterm', 'preservim/vimux' },
  config = function()
    -- .vimtest.json = { "command": "npx vitest" }
    -- vim.g.test_config = { strategy = "vimux" }
    -- local value = vim.api.nvim_get_var('hey')

    -- neovim | vimux
    local strategy = vim.tbl_get(vim.g, 'test_config', 'strategy') or 'neovim'
    -- local strategy = 'neovim'

    -- vim.cmd([[let g:test#javascript#vuetestutils#file_pattern = '']])
    -- vim.cmd([[let g:test#javascript#vuetestutils#executable = "npx vitest"]])
    --
    -- vim.g.test_strategy = strategy
    -- vim.cmd("let test#strategy = '" .. strategy .. "'")

    vim.api.nvim_set_var('test#strategy', strategy)

    vim.cmd([[let test#neovim#term_position = 'vert']])
    vim.cmd([[let g:test#php#phpunit#executable = "./vendor/bin/phpunit"]])
    vim.cmd([[let g:test#php#pest#executable = "./vendor/bin/pest"]])
    vim.cmd("let g:test#enabled_runners = ['php#phpunit']")
    --
    -- docker
    -- :let g:test#php#phpunit#executable = "./vendor/bin/sail bin phpunit"
    -- vim.cmd([[let g:test#php#pest#executable = "./vendor/bin/sail bin pest"]])
    -- vim.cmd([[let g:test#php#phpunit#executable = "docker compose exec php ./vendor/bin/pest"]])
  end,
}
