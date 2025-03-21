local async_formatting = function(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  vim.lsp.buf_request(bufnr, 'textDocument/formatting', vim.lsp.util.make_formatting_params({}), function(err, res, ctx)
    if err then
      local err_msg = type(err) == 'string' and err or err.message
      -- you can modify the log message / level (or ignore it completely)
      vim.notify('formatting: ' .. err_msg, vim.log.levels.WARN)
      return
    end

    -- don't apply results if buffer is unloaded or has been modified
    if not vim.api.nvim_buf_is_loaded(bufnr) or vim.api.nvim_buf_get_option(bufnr, 'modified') then
      return
    end

    if res then
      local client = vim.lsp.get_client_by_id(ctx.client_id)
      vim.lsp.util.apply_text_edits(res, bufnr, client and client.offset_encoding or 'utf-16')
      vim.api.nvim_buf_call(bufnr, function()
        vim.cmd('silent noautocmd update')
      end)
    end
  end)
end

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

        null_ls.builtins.formatting.stylua,
        null_ls.builtins.formatting.prettier.with({

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

        require('user.plugins.duster').with({
          condition = function(utils)
            return utils.root_has_file({ 'vendor/bin/duster' })
          end,
        }),

        require('none-ls.diagnostics.eslint').with({
          condition = function(utils)
            return utils.root_has_file({ '.eslintrc.js', '.eslintrc.json', '.eslintrc.yaml', '.eslintrc.yml' })
          end,
        }),
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
              vim.lsp.buf.format({ async = false, timeout_ms = 2000 })
              -- vim.lsp.buf.format({ bufnr = bufnr, timeout_ms = 5000 })
              -- vim.lsp.buf.formatting_sync()
              -- async_formatting(bufnr)
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

    -- local autocmd_group_duster = vim.api.nvim_create_augroup('CustomAutocommands', { clear = true })

    -- vim.api.nvim_create_autocmd('BufWritePost', {
    --   group = autocmd_group_duster,
    --   pattern = '*.php', -- Trigger only for PHP files
    --   callback = function()
    --     local duster_path = vim.fn.getcwd() .. '/vendor/bin/duster'

    --     -- return not utils.root_has_file({ 'vendor/bin/pint' }) == false
    --     local file_path = vim.fn.expand('%:p')

    --     -- Check if Duster exists in the project
    --     if vim.fn.filereadable(duster_path) == 1 then
    --       local cmd = string.format('%s fix %s', duster_path, file_path)

    --       vim.fn.jobstart(cmd, {
    --         cwd = vim.fn.getcwd(),
    --         on_exit = function(_, exit_code)
    --           if exit_code == 0 then
    --             print('Duster fix completed successfully for ' .. file_path)
    --             -- Reload the file
    --             -- vim.cmd('edit!')
    --             -- Save cursor position
    --             -- local cursor_pos = vim.api.nvim_win_get_cursor(0)

    --             -- Reload the file
    --             vim.cmd('edit!')

    --             -- -- Restore cursor position
    --             -- vim.api.nvim_win_set_cursor(0, cursor_pos)

    --             print('File reloaded, cursor position restored')

    --           else
    --             print('Duster fix encountered an error for ' .. file_path)
    --           end
    --         end,
    --       })
    --     else
    --       print('Duster not found in this project. Skipping fix.')
    --     end
    --   end,
    -- })
  end,
}
