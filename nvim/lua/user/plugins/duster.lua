local h = require('null-ls.helpers')
local u = require('null-ls.utils')
local methods = require('null-ls.methods')

local FORMATTING = methods.internal.FORMATTING
--
-- none-ls.nvim/lua/null-ls/builtins/formatting/phpcsfixer.lua at main · nvimtools/none-ls.nvim
-- https://github.com/nvimtools/none-ls.nvim/blob/main/lua/null-ls/builtins/formatting/phpcsfixer.lua
--
return h.make_builtin({
  name = 'duster',
  meta = {
    url = 'https://github.com/tighten/duster',
    description = 'An opinionated PHP code style fixer for minimalists.',
  },
  method = FORMATTING,
  filetypes = { 'php' },
  generator_opts = {
    command = vim.fn.executable('./vendor/bin/duster') == 1 and './vendor/bin/duster' or 'duster',
    -- args = {
    --   '--no-interaction',
    --   '--quiet',
    --   '$FILENAME',
    -- },
    args = {
      'fix',
    },
    cwd = h.cache.by_bufnr(function(params)
      return u.root_pattern('pint.json', 'composer.json', 'composer.lock')(params.bufname)
    end),
    to_stdin = false,
    to_temp_file = true,
  },
  factory = h.formatter_factory,
})
