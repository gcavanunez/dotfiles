return {
  'nvimtools/none-ls.nvim',
  dependencies = {
    'nvimtools/none-ls-extras.nvim',
  },
  config = function()
    local augroup = vim.api.nvim_create_augroup('LspFormatting', {})

    local null_ls = require('null-ls')
    null_ls.setup({
      debug = true,
      temp_dir = '/tmp',
      sources = {

        null_ls.builtins.diagnostics.trail_space.with({ disabled_filetypes = { 'NvimTree' } }),

        null_ls.builtins.formatting.stylua,
        null_ls.builtins.formatting.prettier,
        null_ls.builtins.formatting.pint,

        require('none-ls.diagnostics.eslint'),
        -- require('none-ls.formatting.eslint'),
        -- require('none-ls.formatting.eslint'),
      },
      on_attach = function(client, bufnr)
        if client.supports_method('textDocument/formatting') then
          vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
          -- vim.api.nvim_buf_set_option(bufnr, 'formatexpr', '')

          vim.api.nvim_create_autocmd('BufWritePre', {
            group = augroup,
            buffer = bufnr,
            callback = function()
              -- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
              -- on later neovim version, you should use vim.lsp.buf.format({ async = false }) instead
              vim.lsp.buf.format({ async = false })
              -- vim.lsp.buf.format({ bufnr = bufnr, timeout_ms = 5000 })
            end,
          })
        end
      end,
    })

    vim.keymap.set('n', '<leader>gf', vim.lsp.buf.format, {})
  end,
}
