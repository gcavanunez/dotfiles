-- PHP language-server stack.
--
-- The defaults below apply everywhere. Override them per project from a
-- trusted .nvim.lua (exrc), which Neovim sources before plugins load:
--
--   vim.g.php_stack = {
--     backend = 'phpantom',
--     blade = { enabled = true, source = 'local' },
--     laravel = { source = 'local' },
--     php_command = { 'docker', 'compose', 'exec', '-T', 'app', 'php' },
--   }
--
-- `source = 'mason'` runs the published Mason package. `source = 'local'` runs
-- the checkout under ~/_code/gcavanunez (build it first). Any entry also
-- accepts an explicit `cmd` list.
local M = {}

M.defaults = {
  -- 'intelephense': intelephense, plus phpactor for rename and code actions.
  -- 'phpantom': PHPantom alone.
  backend = 'intelephense',
  laravel = { enabled = true, source = 'mason' },
  blade = { enabled = false, source = 'mason' },
  phpantom = { source = 'mason' },
  -- Command laravel_lsp and blade_lsp use to run PHP. nil uses `php` on PATH.
  php_command = nil,
}

local mason_cmds = {
  laravel = { 'laravel-lsp' },
  blade = { 'blade-lsp', '--stdio' },
  phpantom = { 'phpantom_lsp' },
}

local local_cmds = {
  laravel = { 'php', vim.fn.expand('~/_code/gcavanunez/lsp/server') },
  blade = { 'node', vim.fn.expand('~/_code/gcavanunez/blade-lsp/dist/server.js'), '--stdio' },
  phpantom = { vim.fn.expand('~/_code/gcavanunez/phpantom_lsp/target/debug/phpantom_lsp') },
}

-- Mason packages the stack can use; installed on demand.
M.mason_packages = { 'laravel_lsp', 'phpantom_lsp', 'blade-lsp' }

function M.get()
  return vim.tbl_deep_extend('force', M.defaults, vim.g.php_stack or {})
end

function M.cmd(stack, name)
  local entry = stack[name]
  if entry.cmd then
    return entry.cmd
  end
  return entry.source == 'local' and local_cmds[name] or mason_cmds[name]
end

function M.ensure_installed()
  local registry = require('mason-registry')
  registry.refresh(function()
    for _, name in ipairs(M.mason_packages) do
      local ok, pkg = pcall(registry.get_package, name)
      if ok and not pkg:is_installed() then
        pkg:install()
      end
    end
  end)
end

return M
