local h = require('null-ls.helpers')
local u = require('null-ls.utils')
local methods = require('null-ls.methods')

local FORMATTING = methods.internal.FORMATTING
--
-- none-ls.nvim/lua/null-ls/builtins/formatting/phpcsfixer.lua at main · nvimtools/none-ls.nvim
-- https://github.com/nvimtools/none-ls.nvim/blob/main/lua/null-ls/builtins/formatting/phpcsfixer.lua
-- https://github.com/nvimtools/none-ls.nvim/blob/main/lua/null-ls/builtins/formatting/pint.lua
--
return h.make_builtin({
  -- name = 'duster',
  -- meta = {
  --   url = 'https://github.com/tighten/duster',
  --   description = 'An opinionated PHP code style fixer for minimalists.',
  -- },
  -- method = FORMATTING,
  -- filetypes = { 'php' },
  -- generator_opts = {
  --   command = vim.fn.executable('./vendor/bin/duster') == 1 and './vendor/bin/duster' or 'duster',
  --   -- args = {
  --   --   '--no-interaction',
  --   --   '--quiet',
  --   --   '$FILENAME',
  --   -- },
  --   args = {
  --     'fix',
  --     '--dirty',
  --     '--no-interaction',
  --     '--quiet',
  --   },
  --   cwd = h.cache.by_bufnr(function(params)
  --     return u.root_pattern('pint.json', 'composer.json', 'composer.lock')(params.bufname)
  --   end),
  --   to_stdin = true,
  --   to_temp_file = false,
  --   format = nil,
  --   check_exit_code = function(code, stderr)
  --     local success = code <= 1

  --     if not success then
  --       -- can be noisy for things that run often (e.g. diagnostics), but can
  --       -- be useful for things that run on demand (e.g. formatting)
  --       print(stderr)
  --     end

  --     return success
  --   end,
  -- },
  -- factory = h.formatter_factory,
  name = 'duster',
  meta = {
    url = 'https://github.com/tighten/duster',
    description = 'An opinionated PHP code style fixer for minimalists.',
  },
  method = FORMATTING,
  filetypes = { 'php' },
  generator_opts = {
    command = vim.fn.executable('./vendor/bin/duster') == 1 and './vendor/bin/duster' or 'duster',
    args = {
      'fix',
      '$FILENAME',
      '--no-interaction',
      '--quiet',
    },
    cwd = h.cache.by_bufnr(function(params)
      return u.root_pattern('duster.json', 'composer.json', 'composer.lock')(params.bufname)
    end),
    to_stdin = true,
    to_temp_file = true,
  },
  factory = h.formatter_factory,
})
