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

local function sessionizer_client(ctx)
  if not ctx.server then return ctx.client_id end

  -- A remote-context action still runs in this server's config, and its
  -- client ID belongs here. Look up the same app's connection on the target.
  -- rex.exec runs locally, unlike rex.call, which follows ctx.server.
  local inspected, err = rex.exec({ 'rex', 'client', 'inspect', ctx.client_id, '--json' }, { timeout = 5 })
  if not inspected then error(err, 0) end
  if not inspected.ok then error('Could not identify the originating Rex app: ' .. inspected.stderr, 0) end
  local source, decode_err = rex.json.decode(inspected.stdout)
  if not source then error(decode_err, 0) end
  local info = source.client and source.client.info
  if not info or info.kind ~= 'app' or not info.label or info.label == '' then
    error('The originating Rex app needs a device label for remote session selection.', 0)
  end

  local clients, list_err = rex.call('client.list', {})
  if not clients then error(list_err, 0) end
  local target
  for _, client in ipairs(clients.clients or {}) do
    local candidate = client.info or {}
    if client.connection_state == 'connected' and candidate.kind == 'app'
      and candidate.label == info.label and candidate.platform == info.platform
      and candidate.name == info.name then
      if target then error('Multiple remote Rex apps share this device label; use distinct labels.', 0) end
      target = client.client_id
    end
  end
  if not target then error('The originating Rex app is not connected to ' .. ctx.server .. '.', 0) end
  return target
end

rex.action({
  name = 'project_sessionizer',
  title = 'Choose Project or Session',
  description = 'Open a floating fzf picker for Rex sessions and project directories.',
  category = 'Session',
  run = function(ctx)
    if not ctx.client_id or not ctx.session_id then
      error('Open the sessionizer from the Rex app, or run rex-sessionizer in a terminal.', 0)
    end
    local client_id = sessionizer_client(ctx)
    local window_id
    if ctx.block_id then
      local described, err = rex.session.describe_block({ block_id = ctx.block_id })
      if not described then error(err, 0) end
      window_id = described.block.window_id
    else
      local view, err = rex.session.view({})
      if not view then error(err, 0) end
      window_id = view.active_window_id
    end
    if not window_id then error('Open the sessionizer from a pane in a Rex tab.', 0) end
    local layer, err = rex.session.new_layer({
      window_id = window_id,
      bounds = { 0.1, 0.15, 0.8, 0.7 },
      focus = true,
      layout = rex.layout.block({
        flavor = 'com.superlogical.terminal.shell',
        label = 'Projects',
        options = {
          -- This terminal can run on a different host from the config action.
          -- Expand HOME there, not here, and keep the client ID as an argument.
          command = {
            'sh', '-c', 'exec "$HOME/.local/bin/rex-sessionizer" "$@"',
            'rex-sessionizer', '--client', client_id,
          },
        },
      }),
    })
    if not layer then error(err, 0) end
    -- Keep the originating app on the existing tab containing the floating
    -- picker, including when the action runs for a remote session.
    local selection = {
      session_id = ctx.session_id,
      window_id = window_id,
    }
    if not ctx.server then rex.client.queue('session.select', selection) end
    -- Keep the existing layout-update grace period before selecting the tab.
    -- https://discord.com/channels/1546797889009881158/1560295127203717161
    local pause, pause_err = rex.exec({ 'sleep', '0.3' }, { timeout = 1 })
    if not pause then error(pause_err, 0) end
    if not pause.ok then error('Could not wait for the floating picker: ' .. pause.stderr, 0) end
    if ctx.server then
      -- Queued client actions have no server field and run against the app's
      -- home connection. Perform this one through the session's server instead.
      local selected, select_err = rex.call('client.perform', {
        client_id = client_id,
        session_id = ctx.session_id,
        action = 'session.select',
        args = selection,
      })
      if not selected then error(select_err, 0) end
    end
    return layer
  end,
})

-- Match the tmux sessionizer: prefix Ctrl+Space, then f.
rex.bind('ctrl+space>f', 'project_sessionizer')
