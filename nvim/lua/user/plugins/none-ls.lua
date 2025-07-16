return {
  'nvimtools/none-ls.nvim',
  dependencies = {
    'nvimtools/none-ls-extras.nvim',
  },
  config = function()
    local augroup = vim.api.nvim_create_augroup('LspFormatting', {})

    local null_ls = require('null-ls')
    null_ls.setup({
      -- debug = true,
      temp_dir = '/tmp',
      sources = {
        -- null_ls.builtins.diagnostics.credo,
        null_ls.builtins.formatting.mix,

        null_ls.builtins.diagnostics.trail_space.with({
          disabled_filetypes = { 'NvimTree' },
          condition = function(utils)
            return not utils.root_has_file({ 'vendor/bin/pint' }) == false
          end,
        }),
        null_ls.builtins.formatting.gofmt,
        null_ls.builtins.formatting.stylua,
        -- null_ls.builtins.formatting.rustfmt
        null_ls.builtins.formatting.prettier.with({
          --      prefer_local = 'node_modules/.bin',
          condition = function(utils)
            return utils.root_has_file({ '.prettierrc', '.prettierrc.json', '.prettierrc.yml', '.prettierrc.js',
              'prettier.config.js', 'prettier.config.cjs', '.prettierrc.cjs' })
          end,
          -- condition = function(utils)
          --   return not utils.root_has_file({ 'vendor/bin/pint' }) == false
          -- end,
          -- extra_filetypes = { 'blade.php' },
          filetypes = {
            'javascript',
            'javascriptreact',
            'typescript',
            'typescriptreact',
            'vue',
            'css',
            'scss',
            'less',
            'html',
            'json',
            'jsonc',
            'yaml',
            'mdx',
            'markdown',
            'markdown.mdx',
            'graphql',
            'handlebars',
            'astro',
            'blade',
          },
        }),

        -- null_ls.builtins.formatting.pint,
        null_ls.builtins.formatting.pint.with({
          condition = function(utils)
            return utils.root_has_file({ 'vendor/bin/pint' }) and utils.root_has_file({ 'vendor/bin/duster' }) == false
          end,
        }),

        -- require('user.plugins.duster')
        null_ls.builtins.formatting.duster.with({
          condition = function(utils)
            return utils.root_has_file({ 'vendor/bin/duster' })
          end,
        }),
      },
      on_attach = function(client, bufnr)
        if client:supports_method('textDocument/formatting') then
          vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
          vim.api.nvim_create_autocmd('BufWritePre', {
            group = augroup,
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({ async = false, timeout_ms = 2000 })
            end,
          })

          -- vim.api.nvim_create_autocmd('BufWritePost', {
          --   group = augroup,
          --   pattern = '*',
          --   callback = function()
          --     -- Your command here
          --     vim.cmd("")
          --   end,
          -- })
        end
      end,
    })

    vim.keymap.set('n', '<leader>gf', vim.lsp.buf.format, {})
    vim.keymap.set('v', '<leader>gf', vim.lsp.buf.format, {})
  end,
}
