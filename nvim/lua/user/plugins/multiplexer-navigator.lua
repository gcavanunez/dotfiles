local source = vim.fn.resolve(debug.getinfo(1, 'S').source:sub(2))
local dotfiles = vim.fn.fnamemodify(source, ':h:h:h:h:h')

return {
  'christoomey/vim-tmux-navigator',
  dependencies = {
    {
      name = 'vim-rex-navigator',
      dir = dotfiles .. '/rex/vendor/vim-rex-navigator',
      cond = vim.env.REX_SESSION ~= nil and vim.env.REX_SESSION ~= '',
      opts = { focus = false, move = false, resize = false, close = false },
    },
  },
  init = function()
    vim.g.tmux_navigator_no_mappings = 1
  end,
  config = function()
    local directions = {
      h = { tmux = 'TmuxNavigateLeft', herdr = 'left' },
      j = { tmux = 'TmuxNavigateDown', herdr = 'down' },
      k = { tmux = 'TmuxNavigateUp', herdr = 'up' },
      l = { tmux = 'TmuxNavigateRight', herdr = 'right' },
    }

    local function navigate(direction)
      local target = directions[direction]

      -- The inner multiplexer owns navigation when nested inside Rex.
      if vim.env.TMUX and vim.env.TMUX ~= '' then
        vim.cmd(target.tmux)
        return
      end

      if vim.env.HERDR_ENV ~= '1' then
        if vim.env.REX_SESSION and vim.env.REX_SESSION ~= '' then
          require('vim-rex-navigator').focus(target.herdr)
        else
          vim.cmd(target.tmux)
        end
        return
      end

      local current_window = vim.api.nvim_get_current_win()
      local moved = pcall(vim.cmd.wincmd, direction)
      if moved and current_window ~= vim.api.nvim_get_current_win() then
        return
      end

      vim.system({
        'herdr',
        'pane',
        'focus',
        '--direction',
        target.herdr,
        '--current',
      }, { detach = true })
    end

    for direction, _ in pairs(directions) do
      vim.keymap.set('n', '<C-' .. direction .. '>', function()
        navigate(direction)
      end, { desc = 'Navigate window or multiplexer pane', silent = true })
    end

    vim.keymap.set('n', '<C-\\>', '<cmd>TmuxNavigatePrevious<CR>', {
      desc = 'Navigate to previous tmux pane',
      silent = true,
    })
  end,
}
