# Rex

## Navigation

`Ctrl+h/j/k/l` navigates Neovim splits, then Rex panes at an editor edge.
Shell panes move directly between Rex panes. Focus does not wrap. Move, resize,
and close shortcuts are left alone, as are the app's default focus shortcuts.

The Lua portions of `pankrashin/vim-rex-navigator` are copied into
`vendor/vim-rex-navigator`; neither Rex nor Neovim downloads this plugin.
See its `UPSTREAM.md` for the source revision, license, and local patches.
Lazy loads this local copy only when `REX_SESSION` is set. Neovim's existing
`multiplexer-navigator.lua` owns the mappings, with tmux taking precedence,
then Herdr, then Rex. Outside Rex, existing navigation remains unchanged.

## Install

Run the dotfiles `install` script. It links `init.lua`, `vendor`, and `themes` under
`${XDG_CONFIG_HOME:-$HOME/.config}/rex`, refusing to replace unrelated files.
Rex's server state and Tailscale credentials are not part of these dotfiles.
The installer also links `rex-sessionizer` into `~/.local/bin`.

Then validate and load the bindings:

```sh
rex config check
rex config reload
```

Restart Neovim to load the updated navigation configuration. For remote Rex
servers, install the configuration and reload it on the remote machine too.

## Colors

`themes/TokyoNight Storm` vendors the exact Ghostty palette selected in
`ghostty/config`. It is linked into Rex's config directory by `install`;
Ghostty does not need to be installed to import it.

Theme selection belongs to each Rex app, not to the shared server/session.
On each Mac, run `rex client ls` to find its app's client ID, then import:

```sh
rex -C CLIENT do client.theme.import \
  "path=${XDG_CONFIG_HOME:-$HOME/.config}/rex/themes/TokyoNight Storm"
```

Replace `CLIENT` with that Mac's app ID. The path is read by the selected app
on its own machine, so run the command on that same Mac (not a different host
whose `$HOME` may be different). Alternatively, use Cmd+Shift+P → Import Theme
File and choose this repo's theme file on that Mac.

Importing selects and stores the theme in the app. It does not change fonts,
keybindings, or shaders, and `install` does not change your selected theme.
After editing the vendored colors, import again; the app does not watch this file.

## Check behavior

- Open Neovim in Rex with two editor splits and an adjacent Rex shell pane.
- Use Ctrl+h/j/k/l inside Neovim: cross editor splits before leaving the editor.
- At the edge, cross into the adjacent Rex pane, then navigate back.
- Confirm existing tmux and Herdr navigation still works, including inside Rex.
- Confirm normal Neovim navigation works outside any multiplexer.

Foreground-process detection is best effort: an editor running over SSH or
behind a PTY proxy may not be recognized, causing Rex to handle its keys.
In a nested tmux/Herdr session, navigation stays with the inner multiplexer;
crossing its outer boundary into Rex is not implemented.

## Project sessionizer

Press **Ctrl+Space, then F**, or run **Choose Project or Session** from Rex's
command palette. An fzf picker opens in a centered floating pane over the current
tab, taking 80% of its width and 70% of its height without changing the tiled
layout. It closes on selection or Esc/Ctrl+C; cancellation returns focus to the
previous pane. You can also run `rex-sessionizer` in a terminal.

The picker runs non-interactively, so it does not read `.zshrc`. On macOS the
script adds missing Homebrew binary directories to `PATH`, making `fzf` and
`jq` available even when Homebrew is initialized only by your interactive shell.

Opening the picker retains a 0.3-second layout-update grace period from Rex's
[new-tab selection race](https://discord.com/channels/1546797889009881158/1560295127203717161).
The picker no longer creates a tab, but the pause is kept conservatively while
the app receives the floating pane's layout. This is not an upstream fix.

- Pick `[REX] ...` to switch to an existing session.
- Pick a project directory to reuse a session with a terminal working in that
  exact directory, or create a new session there. Reusing a session also selects
  the matching tab and focuses its pane, even if that session is already open
  on a different project. Matching uses the full path, not the directory's
  basename. If every terminal has changed directory, a new session may be
  created; choose the existing session entry to avoid this.
- Project roots come from the same
  `~/.config/tmux-sessionizer/tmux-sessionizer.conf` as tmux/Herdr, including
  `TS_EXTRA_SEARCH_PATHS`, `TS_MAX_DEPTH`, and `path:depth` entries. The XDG config
  override is respected.
- Only sessions and directories on the current Rex host are listed. Install the
  script, config, `fzf`, and `jq` on remote hosts where you use the picker.
- The launcher expands `$HOME` inside the target terminal, so each host uses
  its own `~/.local/bin/rex-sessionizer` and project-root configuration. It does
  not copy the script to remote hosts. If it is missing, install these dotfiles
  there and check `ls -l "$HOME/.local/bin/rex-sessionizer"` on that host.
- When the app runs its home config for a remote session, the launcher resolves
  that app's separate client ID on the remote server and sends the picker
  selection through that server. Queued `session.select` actions otherwise
  look for the remote session on the home server. Device labels must uniquely
  identify the connected app; missing or ambiguous matches fail before opening
  a picker rather than selecting another device.
- That lookup runs in the local Rex server, not an interactive terminal. The
  launcher resolves `REX_BIN_DIR` or the managed macOS Rex CLI explicitly so it
  also works when the server's `PATH` does not contain `rex`.

Switching the app requires **Settings → Rex Server → Remote Control**. The
shortcut passes the originating client ID so it targets the right app. From a
terminal, use `rex-sessionizer --client CLIENT` if several apps are connected;
without a client, the script only auto-selects when exactly one app is connected.
If switching fails, the selected/created session is kept and an error is shown.

List candidates without opening a picker or changing sessions:

```sh
rex-sessionizer --list
```
