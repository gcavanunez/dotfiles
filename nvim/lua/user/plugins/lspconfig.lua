return {
  'neovim/nvim-lspconfig',
  event = 'VeryLazy',
  dependencies = {
    'saghen/blink.cmp',
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'b0o/schemastore.nvim',
    -- { 'jose-elias-alvarez/null-ls.nvim', dependencies = 'nvim-lua/plenary.nvim' },
    -- 'jayp0521/mason-null-ls.nvim',
  },
  config = function()
    -- Setup Mason to automatically install LSP servers
    require('mason').setup({
      ui = {
        height = 0.8,
      },
    })
    require('mason-lspconfig').setup({
      automatic_installation = true,
      ensure_installed = {
        'lua_ls',
        'volar',
        -- 'js-debug-adapter',
      },
    })
    local capabilities = require('blink.cmp').get_lsp_capabilities()

    -- https://github.com/vuejs/language-tools/issues/3791#issuecomment-2081488147
    local vue_language_server_path = vim.fn.expand('$MASON/packages') ..
    '/vue-language-server' .. '/node_modules/@vue/language-server'

    -- require('lspconfig').ts_ls.setup({
    vim.lsp.config('ts_ls', {
      capabilities = capabilities,
      on_attach = function(client)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentFormattingRangeProvider = false
      end,
      init_options = {
        plugins = {
          {
            name = '@vue/typescript-plugin',
            -- os.getenv("HOME") .. "/.fnm/node-versions/v20.10.0/installation/bin/node",
            -- location = "/Users/guillermocava/Library/Application Support/fnm/node-versions/v20.10.0/installation/lib/node_modules/@vue/vue-language-server",
            location = vue_language_server_path,
            languages = { 'vue' },
          },
        },
      },
      -- https://github.com/LazyVim/LazyVim/discussions/2150
      root_dir = function(...)
        return require('lspconfig.util').root_pattern('.git')(...)
      end,
      filetypes = {
        'javascript',
        'javascriptreact',
        'javascript.jsx',
        'typescript',
        'typescriptreact',
        'typescript.tsx',
        'vue',
        -- 'mdx',
      },
    })

    vim.lsp.enable('ruby_lsp')
    -- require('lspconfig').ruby_lsp.setup({
    --   capabilities = capabilities,
    -- })

    -- require('lspconfig').lua_ls.setup({
    --   capabilities = capabilities,

    --   on_attach = function(client, bufnr)
    --     -- https://github.com/nvimtools/none-ls.nvim/wiki/Avoiding-LSP-formatting-conflicts
    --     client.server_capabilities.documentFormattingProvider = false
    --     client.server_capabilities.documentRangeFormattingProvider = false
    --   end,
    --   settings = {
    --     Lua = {
    --       -- runtime = {
    --       --   version = 'LuaJIT',
    --       --   path = vim.split(package.path, ';'),
    --       -- },
    --       runtime = { version = 'LuaJIT' },
    --       diagnostics = {
    --         globals = { 'vim' },
    --       },
    --       workspace = {
    --         checkThirdParty = false,
    --         -- library = vim.api.nvim_get_runtime_file('', true),
    --         library = {
    --           '${3rd}/luv/library',
    --           unpack(vim.api.nvim_get_runtime_file('', true)),
    --         },
    --         -- library = {
    --         --   [vim.fn.expand('$VIMRUNTIME/lua')] = true,
    --         --   -- [vim.fn.stdpath('config' .. '/lua')] = true,
    --         --   -- [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
    --         -- },
    --       },
    --     },
    --   },
    -- })
    vim.lsp.config('lua_ls', {
      on_init = function(client)
        if client.workspace_folders then
          local path = client.workspace_folders[1].name
          if path ~= vim.fn.stdpath('config') and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then
            return
          end
        end

        client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
          runtime = {
            -- Tell the language server which version of Lua you're using (most
            -- likely LuaJIT in the case of Neovim)
            version = 'LuaJIT',
            -- Tell the language server how to find Lua modules same way as Neovim
            -- (see `:h lua-module-load`)
            path = {
              'lua/?.lua',
              'lua/?/init.lua',
            },
          },
          -- Make the server aware of Neovim runtime files
          workspace = {
            checkThirdParty = false,
            library = {
              vim.env.VIMRUNTIME,
              -- Depending on the usage, you might want to add additional paths
              -- here.
              -- '${3rd}/luv/library'
              -- '${3rd}/busted/library'
            },
            -- Or pull in all of 'runtimepath'.
            -- NOTE: this is a lot slower and will cause issues when working on
            -- your own configuration.
            -- See https://github.com/neovim/nvim-lspconfig/issues/3189
            -- library = {
            --   vim.api.nvim_get_runtime_file('', true),
            -- }
          },
        })
      end,
      settings = {
        Lua = {},
      },
    })

    -- HTML
    -- local capabilities_html = vim.lsp.protocol.make_client_capabilities()
    -- capabilities_html.textDocument.completion.completionItem.snippetSupport = true

    -- require('lspconfig').html.setup({
    vim.lsp.config('html', {
      filetypes = {
        'html',
        'heex',
        'eex',
        'elixir',
        'templ',
      },
      capabilities = capabilities,
      on_attach = function(client)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentFormattingRangeProvider = false
      end,
    })

    -- require('lspconfig').htmx.setup({
    --   capabilities = capabilities,
    -- })
    --
    -- require('lspconfig').stimulus_ls.setup({
    --   capabilities = capabilities,
    -- })
    vim.lsp.enable('stimulus_ls')

    -- GoLang
    -- require('lspconfig').gopls.setup({
    vim.lsp.config('gopls', {
      capabilities = capabilities,
      cmd = { 'gopls' },
      filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
      -- root_dir = util.root_pattern("go.work", "go.mod", ".git"),
      settings = {
        gopls = {
          completeUnimported = true,
          usePlaceholders = true,
          analyses = {
            unusedparams = true,
          },
        },
      },
    })

    -- require('lspconfig').mdx_analyzer.setup({
    --   capabilities = capabilities,
    --   init_options = {
    --     typescript = {
    --       enable = true,
    --     },
    --   },
    --   on_attach = function(client, bufnr)
    --     client.server_capabilities.documentFormattingProvider = false
    --     client.server_capabilities.documentRangeFormattingProvider = false
    --   end,
    -- })

    -- Elixir
    -- require('lspconfig').elixirls.setup({

    vim.lsp.config('elixirls', {
      capabilities = capabilities,
      on_attach = function(client, bufnr)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
      end,
    })

    -- PHP
    -- require('lspconfig').intelephense.setup({
    vim.lsp.config('intelephense', {
      init_options = {
        globalStoragePath = os.getenv('HOME') .. '/.local/share/intelephense',
        storagePath = os.getenv('HOME') .. '/.local/share/intelephense',
      },
      commands = {
        IntelephenseIndex = {
          function()
            -- vim.lsp.buf.execute_command({ command = 'intelephense.index.workspace' })
            vim.lsp.client:exec_cmd({ command = 'intelephense.index.workspace', title = 'Intelephense: Index Workspace' })
          end,
        },
      },
      on_attach = function(client, bufnr)
        -- client.server_capabilities.completionProvider = false
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
        -- client.server_capabilities.typeDefinitionProvider = false
        -- if client.server_capabilities.inlayHintProvider then
        --   vim.lsp.buf.inlay_hint(bufnr, true)
        -- end
      end,
      capabilities = capabilities,
    })

    -- require('lspconfig').phpactor.setup({
    vim.lsp.config('phpactor', {
      capabilities = capabilities,
      on_attach = function(client, bufnr)
        client.server_capabilities.completionProvider = false
        client.server_capabilities.hoverProvider = false
        client.server_capabilities.implementationProvider = false
        client.server_capabilities.referencesProvider = false
        -- client.server_capabilities.renameProvider = false
        client.server_capabilities.selectionRangeProvider = false
        client.server_capabilities.signatureHelpProvider = false
        client.server_capabilities.typeDefinitionProvider = false
        client.server_capabilities.workspaceSymbolProvider = false
        client.server_capabilities.definitionProvider = false
        client.server_capabilities.documentHighlightProvider = false
        client.server_capabilities.documentSymbolProvider = false
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
      end,
      -- filetypes = { 'php', 'blade' },

      init_options = {
        ['language_server_phpstan.enabled'] = false,
        ['language_server_psalm.enabled'] = false,
      },
      handlers = {
        ['textDocument/publishDiagnostics'] = function() end,
      },
    })

    local util = require('lspconfig.util')
    -- local function get_typescript_server_path(root_dir)
    --   local global_ts = '/Users/guillermocava/Library/Application Support/fnm/node-versions/v20.10.0/installation/lib/node_modules/typescript/lib'
    --   -- Alternative location if installed as root:
    --   -- local global_ts = '/usr/local/lib/node_modules/typescript/lib'
    --   local found_ts = ''
    --   local function check_dir(path)
    --     found_ts =  util.path.join(path, 'node_modules', 'typescript', 'lib')
    --     if util.path.exists(found_ts) then
    --       return path
    --     end
    --   end
    --   if util.search_ancestors(root_dir, check_dir) then
    --     return found_ts
    --   else
    --     return global_ts
    --   end
    -- end
    -- Vue, JavaScript, TypeScript
    -- require('lspconfig').volar.setup({
    vim.lsp.config('volar', {
      capabilities = capabilities,
      on_attach = function(client, bufnr)
        -- https://github.com/nvimtools/none-ls.nvim/wiki/Avoiding-LSP-formatting-conflicts
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
      end,
    })

    -- require('lspconfig').volar.setup({
    --   on_attach = function(client, bufnr)
    --     client.server_capabilities.documentFormattingProvider = false
    --     client.server_capabilities.documentFormattingRangeProvider = false
    --   end,
    --   capabilities = capabilities,
    --   filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue', 'json' },
    -- on_new_config = function(new_config, new_root_dir)
    --    new_config.init_options.typescript.tsdk = get_typescript_server_path(new_root_dir)
    --  end,
    -- settings = {
    --     css = {
    --         lint = {
    --             unknownAtRules = "ignore",
    --         },
    --     },

    --     scss = {
    --         lint = {
    --             unknownAtRules = "ignore",
    --         },
    --     },
    -- },
    -- on_attach = function(client, bufnr)
    --   client.server_capabilities.documentFormattingProvider = false
    --   client.server_capabilities.documentRangeFormattingProvider = false

    --   -- client.resolved_capabilities.document_formatting = false
    --   -- if client.server_capabilities.inlayHintProvider then
    --   --   vim.lsp.buf.inlay_hint(bufnr, true)
    --   -- end
    -- end,
    -- init_options = {
    --  typescript = {
    --    tsdk = '/home/mango/.local/share/fnm/node-versions/v20.10.0/installation/lib/node_modules/typescript/lib'
    --  }
    -- },
    -- Enable "Take Over Mode" where volar will provide all JS/TS LSP services
    -- This drastically improves the responsiveness of diagnostic updates on change
    -- })

    -- Tailwind CSS
    -- require('lspconfig').tailwindcss.setup({ capabilities = capabilities })
    vim.lsp.config('tailwindcss', { capabilities = capabilities })

    -- Astro
    -- require('lspconfig').astro.setup({ capabilities = capabilities })
    vim.lsp.config('astro', { capabilities = capabilities })

    -- JSON
    -- require('lspconfig').jsonls.setup({
    vim.lsp.config('jsonls', {
      capabilities = capabilities,
      settings = {
        json = {
          schemas = require('schemastore').json.schemas(),
        },
      },
      root_dir = function(...)
        return require('lspconfig.util').root_pattern('.git')(...)
      end,
    })
    -- require('lspconfig').emmet_language_server.setup({
    vim.lsp.config('emmet_language_server', {
      filetypes = { 'css', 'eruby', 'html', 'javascript', 'javascriptreact', 'less', 'sass', 'scss', 'pug', 'typescriptreact', 'blade' },
      -- Read more about this options in the [vscode docs](https://code.visualstudio.com/docs/editor/emmet#_emmet-configuration).
      -- **Note:** only the options listed in the table are supported.
      init_options = {
        ---@type table<string, string>
        includeLanguages = {},
        --- @type string[]
        excludeLanguages = {},
        --- @type string[]
        extensionsPath = {},
        --- @type table<string, any> [Emmet Docs](https://docs.emmet.io/customization/preferences/)
        preferences = {},
        --- @type boolean Defaults to `true`
        showAbbreviationSuggestions = true,
        --- @type "always" | "never" Defaults to `"always"`
        showExpandedAbbreviation = 'always',
        --- @type boolean Defaults to `false`
        showSuggestionsAsSnippets = false,
        --- @type table<string, any> [Emmet Docs](https://docs.emmet.io/customization/syntax-profiles/)
        syntaxProfiles = {},
        --- @type table<string, string> [Emmet Docs](https://docs.emmet.io/customization/snippets/#variables)
        variables = {},
      },
    })

    -- require('lspconfig').rust_analyzer.setup({
    vim.lsp.config('rust_analyzer', {
      capabilities = capabilities,
      on_attach = function(client, bufnr)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
        -- if client.server_capabilities.inlayHintProvider then
        --   vim.lsp.buf.inlay_hint(bufnr, true)
        -- end
      end,

      settings = {
        ['rust-analyzer'] = {
          cargo = {
            allFeatures = true,
          },
        },
      },
      -- settings = {
      --   ['rust-analyzer'] = {
      --         cargo = {
      --             allFeatures = true,
      --             loadOutDirsFromCheck = true,
      --             runBuildScripts = true,
      --         },
      --         -- Add clippy lints for Rust.
      --         checkOnSave = {
      --             allFeatures = true,
      --             command = "clippy",
      --             extraArgs = { "--no-deps" },
      --         },
      --     diagnostics = {
      --      enable = false;
      --     }
      --   }
      -- }
    })

    -- null-ls
    --local null_ls = require('null-ls')
    --local augroup = vim.api.nvim_create_augroup('LspFormatting', {})
    --null_ls.setup({
    --  debug = true,
    --  temp_dir = '/tmp',
    --  sources = {
    --    -- null_ls.builtins.formatting.gofmt,
    --    -- null_ls.builtins.formatting.goimports_revisor,

    --    null_ls.builtins.formatting.gofumpt,
    --    -- null_ls.builtins.formatting.goimports_reviser,
    --    null_ls.builtins.formatting.golines,

    --    null_ls.builtins.diagnostics.eslint.with({
    --      condition = function(utils)
    --        return utils.root_has_file({ '.eslintrc.js', '.eslintrc.cjs' })
    --      end,
    --    }),
    --    -- null_ls.builtins.diagnostics.phpstan, -- TODO: Only if config file
    --    null_ls.builtins.diagnostics.trail_space.with({ disabled_filetypes = { 'NvimTree' } }),
    --    null_ls.builtins.formatting.eslint.with({
    --      condition = function(utils)
    --        return utils.root_has_file({ '.eslintrc.js', '.eslintrc.json', '.eslintrc.cjs' })
    --      end,
    --    }),
    --    null_ls.builtins.formatting.pint.with({
    --      condition = function(utils)
    --        return utils.root_has_file({ 'vendor/bin/pint' })
    --      end,
    --    }),

    --    null_ls.builtins.formatting.prettier.with({
    --      prefer_local = 'node_modules/.bin',
    --      -- disabled_filetypes = { "vue" },
    --      extra_filetypes = { 'astro' },
    --      condition = function(utils)
    --        return utils.root_has_file({ '.prettierrc', '.prettierrc.json', '.prettierrc.yml', '.prettierrc.js', 'prettier.config.js', 'prettier.config.cjs' })
    --      end,
    --    }),
    --    null_ls.builtins.formatting.rustfmt,
    --    -- null_ls.builtins.formatting.rustfmt.with({
    --    --
    --    --     return utils.is_executable("rustfmt")
    --    -- end,
    --    -- })
    --  },
    --  on_attach = function(client, bufnr)
    --    if client.supports_method('textDocument/formatting') then
    --      vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
    --      vim.api.nvim_buf_set_option(bufnr, 'formatexpr', '')

    --      vim.api.nvim_create_autocmd('BufWritePre', {
    --        group = augroup,
    --        buffer = bufnr,
    --        callback = function()
    --          vim.lsp.buf.format({ bufnr = bufnr, timeout_ms = 5000 })
    --        end,
    --      })
    --    end
    --  end,
    --})

    -- Define an autocmd group for the blade workaround
    local augroup = vim.api.nvim_create_augroup('lsp_blade_workaround', { clear = true })

    -- Autocommand to temporarily change 'blade' filetype to 'php' when opening for LSP server activation
    vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
      group = augroup,
      pattern = '*.blade.php',
      callback = function()
        vim.bo.filetype = 'php'
      end,
    })

    -- Additional autocommand to switch back to 'blade' after LSP has attached
    vim.api.nvim_create_autocmd('LspAttach', {
      pattern = '*.blade.php',
      callback = function(args)
        vim.schedule(function()
          -- Check if the attached client is 'intelephense'
          for _, client in ipairs(vim.lsp.get_clients()) do
            if client.name == 'intelephense' and client.attached_buffers[args.buf] then
              vim.api.nvim_buf_set_option(args.buf, 'filetype', 'blade')
              -- update treesitter parser to blade
              vim.api.nvim_buf_set_option(args.buf, 'syntax', 'blade')
              break
            end
          end
        end)
      end,
    })

    -- make $ part of the keyword for php.
    vim.api.nvim_exec(
      [[
autocmd FileType php set iskeyword+=$
]],
      false
    )
    --require('mason-null-ls').setup({ automatic_installation = true })

    -- Keymaps
    vim.keymap.set('n', '<leader>d', '<cmd>lua vim.diagnostic.open_float()<CR>')
    -- vim.keymap.set('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>')
    -- vim.keymap.set('n', ']d', '<cmd>lua vim.diagnostic.jump()<CR>')
    -- vim.keymap.set('n', ']g', function()
    --   vim.lsp.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
    -- end, { desc = 'Go to next diagnostic warning' })
    vim.keymap.set('n', ']d', function()
      vim.diagnostic.jump({ count = 1 })
    end)
    vim.keymap.set('n', '[d', function()
      vim.diagnostic.jump({ count = -1 })
    end)
    vim.keymap.set('n', 'gd', '<cmd>Telescope lsp_definitions<CR>')
    vim.keymap.set('n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>')
    vim.keymap.set('n', 'gi', '<cmd>Telescope lsp_implementations<CR>')
    vim.keymap.set('n', 'gr', '<cmd>Telescope lsp_references<CR>')
    vim.keymap.set('n', '<leader>lr', '<cmd>LspRestart<CR>')
    vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>')
    vim.keymap.set('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>')

    -- -- Commands
    -- vim.api.nvim_create_user_command('Format', function()
    --   vim.lsp.buf.format({ timeout_ms = 5000 })
    -- end, {})

    -- Diagnostic configuration
    vim.diagnostic.config({
      virtual_text = true,
      float = {
        source = true,
      },
    })

    -- Sign configuration
    -- vim.fn.sign_define('DiagnosticSignError', { text = '', texthl = 'DiagnosticSignError' })
    -- vim.fn.sign_define('DiagnosticSignWarn', { text = '', texthl = 'DiagnosticSignWarn' })
    -- vim.fn.sign_define('DiagnosticSignInfo', { text = '', texthl = 'DiagnosticSignInfo' })
    -- vim.fn.sign_define('DiagnosticSignHint', { text = '', texthl = 'DiagnosticSignHint' })

    -- ' ', ' ', '󰋼 ', ' ',
    vim.diagnostic.config({
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = '',
          [vim.diagnostic.severity.WARN] = '',
          [vim.diagnostic.severity.INFO] = '󰋼',
          [vim.diagnostic.severity.HINT] = '',
        },
        numhl = {
          [vim.diagnostic.severity.ERROR] = '',
          [vim.diagnostic.severity.WARN] = '',
          [vim.diagnostic.severity.HINT] = '',
          [vim.diagnostic.severity.INFO] = '',
        },
      },
    })
  end,
}
