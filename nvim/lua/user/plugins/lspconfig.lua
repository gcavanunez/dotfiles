return {
  'neovim/nvim-lspconfig',
  event = 'VeryLazy',
  dependencies = {
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'b0o/schemastore.nvim',
    { 'jose-elias-alvarez/null-ls.nvim', dependencies = 'nvim-lua/plenary.nvim' },
    'jayp0521/mason-null-ls.nvim',
  },
  config = function()
    -- Setup Mason to automatically install LSP servers
    require('mason').setup({
      ui = {
        height = 0.8,
      },
    })
    require('mason-lspconfig').setup({ automatic_installation = true })

    local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

    local mason_registry = require("mason-registry")
    local vue_language_server_path = mason_registry.get_package("vue-language-server"):get_install_path() .. "/node_modules/@vue/language-server"
    -- https://github.com/vuejs/language-tools/issues/3791#issuecomment-2081488147

    require('lspconfig').tsserver.setup( {
      capabilities = capabilities,
      on_attach = function(client)
        -- client.resolved_capabilities.document_formatting = false
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentFormattingRangeProvider = false

      end,
      init_options = {
        plugins = {
          {
            name = "@vue/typescript-plugin",
            -- os.getenv("HOME") .. "/.fnm/node-versions/v20.10.0/installation/bin/node",
            -- location = "/Users/guillermocava/Library/Application Support/fnm/node-versions/v20.10.0/installation/lib/node_modules/@vue/vue-language-server",
            location = vue_language_server_path,

            languages = {"vue"},
          },
        },
      },
      filetypes = {
        -- "javascript",
        -- "typescript",
        -- "vue",
        "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx", "vue"
      },
    } )

    -- HTML
    local capabilities_html = vim.lsp.protocol.make_client_capabilities()
    capabilities_html.textDocument.completion.completionItem.snippetSupport = true

    require('lspconfig').html.setup({
      capabilities = capabilities,
    })

    require('lspconfig').htmx.setup({
      -- capabilities = capabilities,
    })

    -- GoLang
    require('lspconfig').gopls.setup({
      capabilities = capabilities,
      cmd = {"gopls"},
      filetypes = { "go", "gomod", "gowork", "gotmpl" },
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

    -- Elixir
    require('lspconfig').lexical.setup({
      -- capabilities = capabilities,
    })

    -- PHP
    require('lspconfig').intelephense.setup({
      commands = {
        IntelephenseIndex = {
          function()
            vim.lsp.buf.execute_command({ command = 'intelephense.index.workspace' })
          end,
        },
      },
      on_attach = function(client, bufnr)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
        -- if client.server_capabilities.inlayHintProvider then
        --   vim.lsp.buf.inlay_hint(bufnr, true)
        -- end
      end,
      capabilities = capabilities
    })

    require('lspconfig').phpactor.setup({
      capabilities = capabilities,
      on_attach = function(client, bufnr)
        client.server_capabilities.completionProvider = false
        client.server_capabilities.hoverProvider = false
        client.server_capabilities.implementationProvider = false
        client.server_capabilities.referencesProvider = false
        client.server_capabilities.renameProvider = false
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
      init_options = {
        ["language_server_phpstan.enabled"] = false,
        ["language_server_psalm.enabled"] = false,
      },
      handlers = {
        ['textDocument/publishDiagnostics'] = function() end
      }
    })

    local util = require 'lspconfig.util'
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
    require('lspconfig').volar.setup({
      capabilities = capabilities,
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
    require('lspconfig').tailwindcss.setup({ capabilities = capabilities })

    -- Astro
    require('lspconfig').astro.setup({ capabilities = capabilities })

    -- JSON
    require('lspconfig').jsonls.setup({
      capabilities = capabilities,
      settings = {
        json = {
          schemas = require('schemastore').json.schemas(),
        },
      },
    })

    require('lspconfig').rust_analyzer.setup({
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
            allFeatures = true
          }
        }
      }
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
    local null_ls = require('null-ls')
    local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
    null_ls.setup({
      debug = true,
      temp_dir = '/tmp',
      sources = {
        -- null_ls.builtins.formatting.gofmt,
        -- null_ls.builtins.formatting.goimports_revisor,

        null_ls.builtins.formatting.gofumpt,
        -- null_ls.builtins.formatting.goimports_reviser,
        null_ls.builtins.formatting.golines,

        null_ls.builtins.diagnostics.eslint.with({
          condition = function(utils)
            return utils.root_has_file({ '.eslintrc.js', '.eslintrc.cjs' })
          end,
        }),
        -- null_ls.builtins.diagnostics.phpstan, -- TODO: Only if config file
        null_ls.builtins.diagnostics.trail_space.with({ disabled_filetypes = { 'NvimTree' } }),
        null_ls.builtins.formatting.eslint.with({
          condition = function(utils)
            return utils.root_has_file({ '.eslintrc.js', '.eslintrc.json', '.eslintrc.cjs' })
          end,
        }),
        null_ls.builtins.formatting.pint.with({
          condition = function(utils)
            return utils.root_has_file({ 'vendor/bin/pint' })
          end,
        }),

        null_ls.builtins.formatting.prettier.with({
          prefer_local = "node_modules/.bin",
          -- disabled_filetypes = { "vue" },
          extra_filetypes = {'astro'},
          condition = function(utils)
            return utils.root_has_file({ '.prettierrc', '.prettierrc.json', '.prettierrc.yml', '.prettierrc.js', 'prettier.config.js', 'prettier.config.cjs' })
          end,
        }),
        null_ls.builtins.formatting.rustfmt
        -- null_ls.builtins.formatting.rustfmt.with({
          --
          --     return utils.is_executable("rustfmt")
          -- end,
        -- })

      },
      on_attach = function(client, bufnr)
        if client.supports_method("textDocument/formatting") then
          vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
          vim.api.nvim_buf_set_option(bufnr, "formatexpr", "")

          vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({ bufnr = bufnr, timeout_ms = 5000 })
            end,
          })
        end
      end,
    })

    require('mason-null-ls').setup({ automatic_installation = true })

    -- Keymaps
    vim.keymap.set('n', '<Leader>d', '<cmd>lua vim.diagnostic.open_float()<CR>')
    vim.keymap.set('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>')
    vim.keymap.set('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>')
    vim.keymap.set('n', 'gd', ':Telescope lsp_definitions<CR>')
    vim.keymap.set('n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>')
    vim.keymap.set('n', 'gi', ':Telescope lsp_implementations<CR>')
    vim.keymap.set('n', 'gr', ':Telescope lsp_references<CR>')
    vim.keymap.set('n', '<Leader>lr', ':LspRestart<CR>', { silent = true })
    vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>')
    vim.keymap.set('n', '<Leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>')

    -- Commands
    vim.api.nvim_create_user_command('Format', function() vim.lsp.buf.format({ timeout_ms = 5000 }) end, {})

    -- Diagnostic configuration
    vim.diagnostic.config({
      virtual_text = false,
      float = {
        source = true,
      }
    })

    -- Sign configuration
    vim.fn.sign_define('DiagnosticSignError', { text = '', texthl = 'DiagnosticSignError' })
    vim.fn.sign_define('DiagnosticSignWarn', { text = '', texthl = 'DiagnosticSignWarn' })
    vim.fn.sign_define('DiagnosticSignInfo', { text = '', texthl = 'DiagnosticSignInfo' })
    vim.fn.sign_define('DiagnosticSignHint', { text = '', texthl = 'DiagnosticSignHint' })
  end,
}
