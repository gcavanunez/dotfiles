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
    -- neovim | vimux
    local strategy = vim.tbl_get(vim.g, 'test_config', 'strategy') or 'neovim'

    vim.api.nvim_set_var('test#strategy', strategy)
    vim.cmd([[let test#neovim#term_position = 'vert']])

    -- Dynamically pick vitest vs playwright based on file path.
    -- This prevents vuetestutils from matching (it detects @vue/test-utils
    -- and hardcodes vue-cli-service test:unit).
    vim.api.nvim_create_autocmd('BufEnter', {
      pattern = { '*.spec.ts', '*.spec.js', '*.test.ts', '*.test.js' },
      callback = function()
        local file = vim.fn.expand('%:p')
        if file:match('/e2e/') then
          vim.g['test#javascript#runner'] = 'playwright'
        else
          vim.g['test#javascript#runner'] = 'vitest'
        end
      end,
    })

    -- PHP
    vim.cmd([[let g:test#php#phpunit#executable = "./vendor/bin/phpunit"]])
    vim.cmd([[let g:test#php#pest#executable = "./vendor/bin/phpunit"]])
  end,
}
