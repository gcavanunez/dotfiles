local test_commands = {
  'TestNearest',
  'TestFile',
  'TestSuite',
  'TestLast',
  'TestVisit',
}

local javascript_extensions = {
  cjs = true,
  cts = true,
  js = true,
  jsx = true,
  mjs = true,
  mts = true,
  ts = true,
  tsx = true,
  vue = true,
}

local function get_config()
  return vim.tbl_deep_extend('force', {
    strategy = 'neovim',
    javascript = {
      default_runner = 'vitest',
      e2e_runner = 'playwright',
      e2e_markers = { '/e2e/', '/playwright/', '.e2e.', '.pw.' },
      resolve_runner = nil,
    },
  }, vim.g.test_config or {})
end

local function has_marker(file, markers)
  for _, marker in ipairs(markers) do
    if file:find(marker, 1, true) then
      return true
    end
  end

  return false
end

local function configure_javascript_runner()
  local file = vim.api.nvim_buf_get_name(0)
  local extension = vim.fn.fnamemodify(file, ':e')

  if not javascript_extensions[extension] then
    return
  end

  local javascript = get_config().javascript
  local runner

  if type(javascript.resolve_runner) == 'function' then
    runner = javascript.resolve_runner(file)
  end

  if not runner then
    runner = has_marker(file, javascript.e2e_markers) and javascript.e2e_runner or javascript.default_runner
  end

  vim.g['test#javascript#runner'] = runner
end

local function run_test(command)
  return function()
    configure_javascript_runner()
    vim.cmd(command)
  end
end

return {
  'vim-test/vim-test',
  cmd = test_commands,
  keys = {
    { '<Leader>tn', run_test('TestNearest'), desc = 'Test nearest' },
    { '<Leader>tf', run_test('TestFile'), desc = 'Test file' },
    { '<Leader>tS', run_test('TestSuite'), desc = 'Test suite' },
    { '<Leader>tl', run_test('TestLast'), desc = 'Test last' },
    { '<Leader>tv', run_test('TestVisit'), desc = 'Visit test' },
  },
  dependencies = { 'voldikss/vim-floaterm', 'preservim/vimux' },
  config = function()
    -- neovim | vimux
    local strategy = get_config().strategy

    vim.api.nvim_set_var('test#strategy', strategy)
    vim.cmd([[let test#neovim#term_position = 'vert']])

    -- Dynamically pick vitest vs playwright based on file path.
    -- This prevents vuetestutils from matching (it detects @vue/test-utils
    -- and hardcodes vue-cli-service test:unit).
    local group = vim.api.nvim_create_augroup('UserVimTest', { clear = true })

    vim.api.nvim_create_autocmd('BufEnter', {
      group = group,
      pattern = { '*.cjs', '*.cts', '*.js', '*.jsx', '*.mjs', '*.mts', '*.ts', '*.tsx', '*.vue' },
      callback = configure_javascript_runner,
    })

    -- PHP
    vim.cmd([[let g:test#php#phpunit#executable = "./vendor/bin/phpunit"]])
    vim.cmd([[let g:test#php#pest#executable = "./vendor/bin/phpunit"]])
    -- vim.cmd([[let g:test#php#phpunit#executable = "./vendor/bin/pest"]])
    -- vim.cmd([[let g:test#php#pest#executable = "./vendor/bin/pest"]])
  end,
}
