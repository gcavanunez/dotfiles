return {
  'christoomey/vim-tmux-navigator',
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

      if vim.env.HERDR_ENV ~= '1' then
        vim.cmd(target.tmux)
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
