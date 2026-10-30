-- Both halves of the navigator are vendored; no Neovim plugin install is needed.
require('vendor.vim-rex-navigator.rex.vim-rex-navigator').setup({
  focus_left = 'ctrl+h',
  focus_down = 'ctrl+j',
  focus_up = 'ctrl+k',
  focus_right = 'ctrl+l',
  move = false,
  resize = false,
  close = false,
})

rex.action({
  name = 'project_sessionizer',
  title = 'Choose Project or Session',
  description = 'Open an fzf picker for Rex sessions and project directories.',
  category = 'Session',
  run = function(ctx)
    if not ctx.client_id or not ctx.session_id then
      error('Open the sessionizer from the Rex app, or run rex-sessionizer in a terminal.', 0)
    end
    local window, err = rex.session.new_window({
      window_label = 'Projects',
      focus = true,
      layout = rex.layout.block({
        flavor = 'com.superlogical.terminal.shell',
        options = {
          -- This terminal can run on a different host from the config action.
          -- Expand HOME there, not here, and keep the client ID as an argument.
          command = {
            'sh', '-c', 'exec "$HOME/.local/bin/rex-sessionizer" "$@"',
            'rex-sessionizer', '--client', ctx.client_id,
          },
        },
      }),
    })
    if not window then error(err, 0) end
    -- Updating the server's active window alone does not select the tab in
    -- the originating app. Explicitly show the picker on that client too.
    rex.client.queue('session.select', {
      session_id = ctx.session_id,
      window_id = window.window_id,
    })
    -- Rex can deliver the queued selection before the app knows the new tab.
    -- Let the app receive its layout update before this action returns.
    -- https://discord.com/channels/1546797889009881158/1560295127203717161
    local pause, pause_err = rex.exec({ 'sleep', '0.3' }, { timeout = 1 })
    if not pause then error(pause_err, 0) end
    if not pause.ok then error('Could not wait for the picker tab: ' .. pause.stderr, 0) end
    return window
  end,
})

-- Match the tmux sessionizer: prefix Ctrl+Space, then f.
rex.bind('ctrl+space>f', 'project_sessionizer')
