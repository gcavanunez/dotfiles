-- Turn Supermaven off with SUPERMAVEN=off (or false/0), from the shell, a
-- project's mise.toml [env], or vim.g.supermaven = false in a project's .nvim.lua.
local function disabled()
  local env = (vim.env.SUPERMAVEN or ''):lower()
  return env == 'off' or env == 'false' or env == '0' or vim.g.supermaven == false
end

return {
  'supermaven-inc/supermaven-nvim',
  config = function()
    require('supermaven-nvim').setup({
      keymaps = {
        accept_suggestion = '<C-j>',
        clear_suggestion = '<C-]>',
        accept_word = '<C-l>',
      },
      condition = disabled,
    })
  end,
}
