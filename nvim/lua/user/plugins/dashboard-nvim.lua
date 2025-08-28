local headers = {
  'hack',
  'gengar',
  'pirate',
  'gear-5',
  'luffy',
  'spades',
  'protos',
  '404',
  'blackbird',
  'ragrats',
  'tighten',
}

local function get_random_header()
  math.randomseed(os.time())
  local random_header = headers[math.random(#headers)]
  local ok, header = pcall(require, 'user.art.' .. random_header)
  if ok then
    return header
  else
    return { '', '' }
  end
end

local function get_specific_header(header_name)
  local ok, header = pcall(require, 'user.art.' .. header_name)
  if ok then
    return header
  else
    return { '', '' }
  end
end

local function refresh_dashboard_header(new_header)
  local dashboard = require('dashboard')
  -- Update the configuration
  dashboard.setup({
    theme = 'doom',
    config = {
      header = new_header,
      center = {
        { icon = '  ', desc = 'New file',                 action = 'enew' },
        { icon = '  ', desc = 'Find file               ', key = 'Space + f',                      action = 'Telescope find_files' },
        { icon = '  ', desc = 'Recent files            ', key = 'Space + h',                      action = 'Telescope oldfiles' },
        { icon = '  ', desc = 'Find Word               ', key = 'Space + gg',                     action = 'Telescope live_grep' },
        { icon = '  ', desc = 'Find Project            ', action = 'lua Snacks.picker.projects()' },
      },
      footer = { '' },
    },
    hide = {
      statusline = false,
      tabline = false,
      winbar = false,
    },
  })

  -- Refresh dashboard if it's currently open
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == 'dashboard' then
      vim.cmd('Dashboard')
      break
    end
  end
end

return {
  'glepnir/dashboard-nvim',
  opts = {
    theme = 'doom',
    config = {
      header = get_random_header(),
      center = {
        { icon = '  ', desc = 'New file',                 action = 'enew' },
        { icon = '  ', desc = 'Find file               ', key = 'Space + f',                      action = 'Telescope find_files' },
        { icon = '  ', desc = 'Recent files            ', key = 'Space + h',                      action = 'Telescope oldfiles' },
        { icon = '  ', desc = 'Find Word               ', key = 'Space + gg',                     action = 'Telescope live_grep' },
        { icon = '  ', desc = 'Find Project            ', action = 'lua Snacks.picker.projects()' },
      },
      footer = { '' },
    },
    hide = {
      statusline = false,
      tabline = false,
      winbar = false,
    },
  },
  init = function()
    vim.api.nvim_set_hl(0, 'DashboardHeader', { fg = '#6272a4' })
    vim.api.nvim_set_hl(0, 'DashboardDesc', { fg = '#f8f8f2' })
    vim.api.nvim_set_hl(0, 'DashboardIcon', { fg = '#bd93f9' })
    vim.api.nvim_set_hl(0, 'DashboardKey', { fg = '#6272a4' })
    vim.api.nvim_set_hl(0, 'DashboardFooter', { fg = '#6272a4' })

    -- Create user commands for changing headers
    vim.api.nvim_create_user_command('DashboardHeader', function(opts)
      local header_name = opts.args
      if header_name == '' then
        local available_headers = table.concat(headers, ', ') .. ', random'
        print('Available headers: ' .. available_headers)
        return
      end

      local new_header
      if header_name == 'random' then
        new_header = get_random_header()
      else
        new_header = get_specific_header(header_name)
      end

      refresh_dashboard_header(new_header)
    end, {
      nargs = '?',
      complete = function()
        return headers
      end,
      desc = 'Change dashboard header',
    })

    -- https://github.com/nvimdev/dashboard-nvim/issues/372#issuecomment-1975279729
    vim.defer_fn(function()
      vim.api.nvim_create_autocmd('BufDelete', {
        group = vim.api.nvim_create_augroup('open-dashboard-after-last-buffer-close', { clear = true }),
        callback = function(event)
          for buf = 1, vim.fn.bufnr('$') do
            if buf ~= event.buf and vim.fn.buflisted(buf) == 1 then
              if vim.api.nvim_buf_get_name(buf) ~= '' and vim.bo[buf].filetype ~= 'dashboard' then
                return
              end
            end
          end
          vim.cmd('Dashboard')
        end,
      })
    end, 0)
  end,
}
