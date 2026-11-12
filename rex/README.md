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
The installer also links `rex-sessionizer` and `rex-copy-mode` into `~/.local/bin`,
and `copy-mode.lua` into Rex's config directory.

Then validate and load the bindings:

```sh
rex config check
rex config reload
```

Restart Neovim to load the updated navigation configuration. For remote Rex
servers, install the configuration and reload it on the remote machine too.

## Update Rex on Omarchy

Like the other `scripts/upgrade-*` commands, run this on the machine being
updated, from an SSH session or a terminal **outside Rex**:

```sh
~/dotfiles/scripts/upgrade-rex
```

It runs `omarchy update` with its normal confirmation/sudo prompts, then stops
and starts the personal Rex server and prints its status. If the update fails,
Rex is left running. This updates system packages too, not just Rex, and a
successful run restarts Rex even when the Rex package did not change.
**The restart ends programs in all Rex sessions.** There is no additional
restart prompt, remote connection, service migration, or automatic reboot.

Before the first run, put the server's existing start options in the private,
machine-local `${XDG_CONFIG_HOME:-$HOME/.config}/rex/upgrade.conf`, for example:

```bash
REX_START_ARGS=()  # no extra flags; otherwise use this machine's actual options
```

For embedded Tailscale, add `--tailscale` and `--tailscale-hostname` with the
existing private hostname to that array. Keep this file outside the checkout,
do not symlink it into dotfiles, and restrict it to your account (`chmod 600`).
It is sourced as trusted Bash configuration. The updater refuses to run if it
is missing, rather than silently dropping the server's existing options.

No machine address, hostname, host ID, or SSH target belongs in this public
updater. Start options stay local, as do server state and credentials.
See [first-party upgrade/restart support](UPGRADING.md) for the checked Rex docs.

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
- New sessions use the selected directory's basename as their session name;
  tab/window names are left to Rex's defaults. Existing names are not changed.
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

## Snapshot copy mode (trial)

Press **Ctrl+Space, then [**, or choose **Copy Pane Snapshot** from the command
palette. A nearly full-tab floating, read-only Neovim viewer opens at the bottom
of the source pane's captured output. The original program keeps running.

- Use Vim motions, `gg`/`G`, Ctrl+U/D, and `/`/`?` to navigate and search.
- `v`, `V`, or Ctrl+V starts character, line, or rectangular selection.
- `y` copies a selection and closes; normal-mode `yy` copies the current line.
- Enter copies the selection (or current line) and closes.
- `q`, Esc, or Ctrl+C cancels without copying. Focus returns to the source pane.

This is **not native Rex copy mode**: it is a plain-text snapshot, without live
updates or terminal colors. Normal shell scrollback is included; alternate-screen
apps (Neovim, OpenCode, lazygit, etc.) expose only their current visible screen,
not their hidden history. Soft-wrapped lines are joined before viewing.

Neovim 0.10+ with `vim.ui.clipboard.osc52` is required on each terminal host.
The viewer ignores your Neovim configuration/plugins and disables modelines,
swap, undo files, and clipboard reads. Copying uses OSC52 through Rex to the
viewing app's clipboard, not `pbcopy` or Wayland on the remote machine. Rex must
allow terminal clipboard writes and be active (background writes were ignored
in the tested Mac build). Other apps viewing the same pane may also
receive clipboard writes; the floating layer and its focus are shared session
state, not a private per-device view.

Capturing and private temporary files stay on the source host; normal exit or
cancellation removes them. A force-kill/crash can leave a `rex-copy-mode.*`
temporary directory behind. Install both new links on remote hosts and reload
their configs as well as the app's home config. No server restart is required.

Inspired by the snapshot-viewer approach in the
[community copy-mode thread](https://discord.com/channels/1546797889009881158/1558373508117958686)
and [catsby's example](https://gist.github.com/catsby/0fd3d65ae905ee645a5e7de89b17b5df).
This implementation captures on the target host and uses OSC52 instead of the
example's host-local temporary files and clipboard provider.
