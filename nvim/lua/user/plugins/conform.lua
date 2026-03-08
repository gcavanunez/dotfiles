return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>gf',
      function()
        require('conform').format({ async = false, lsp_format = 'fallback', timeout_ms = 2000 })
      end,
      mode = { 'n', 'v' },
      desc = 'Format buffer',
    },
  },
  opts = {
    formatters_by_ft = {
      lua = { 'stylua' },
      go = { 'gofmt' },
      elixir = { 'mix' },
      php = function(bufnr)
        if vim.fn.filereadable('vendor/bin/duster') == 1 then
          return { 'duster' }
        elseif vim.fn.filereadable('vendor/bin/pint') == 1 then
          return { 'pint' }
        end
        return {}
      end,
      javascript = { 'prettier', 'oxfmt', stop_after_first = true },
      javascriptreact = { 'prettier', 'oxfmt', stop_after_first = true },
      typescript = { 'prettier', 'oxfmt', stop_after_first = true },
      typescriptreact = { 'prettier', 'oxfmt', stop_after_first = true },
      vue = { 'prettier', 'oxfmt', stop_after_first = true },
      css = { 'prettier' },
      scss = { 'prettier' },
      less = { 'prettier' },
      html = { 'prettier' },
      json = { 'prettier' },
      jsonc = { 'prettier' },
      yaml = { 'prettier' },
      markdown = { 'prettier' },
      ['markdown.mdx'] = { 'prettier' },
      mdx = { 'prettier' },
      graphql = { 'prettier' },
      handlebars = { 'prettier' },
      astro = { 'prettier' },
      blade = { 'prettier' },
    },
    format_on_save = function(bufnr)
      return { timeout_ms = 2000, lsp_format = 'fallback' }
    end,
    formatters = {
      prettier = {
        condition = function(self, ctx)
          return vim.fs.find({
            '.prettierrc',
            '.prettierrc.json',
            '.prettierrc.yml',
            '.prettierrc.js',
            'prettier.config.js',
            'prettier.config.cjs',
            '.prettierrc.cjs',
          }, { path = ctx.dirname, upward = true })[1] ~= nil
        end,
      },
      pint = {
        command = 'vendor/bin/pint',
      },
      duster = {
        command = 'vendor/bin/duster',
        args = { 'fix', '$FILENAME', '--no-interaction', '--quiet' },
        stdin = false,
      },
    },
  },
}
