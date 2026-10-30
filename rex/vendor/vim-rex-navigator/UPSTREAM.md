# Vendored vim-rex-navigator

- Source: https://github.com/pankrashin/vim-rex-navigator
- Revision: `fc3d07c0468148fec120b5a8de183b7dc97a32b8`
- License: MIT (see `LICENSE`)
- Copied files: `lua/vim-rex-navigator.lua`, `plugin/vim-rex-navigator.lua`,
  `rex/vim-rex-navigator.lua`, `LICENSE`.

Local changes in the Rex module:

- The `VIM` process table also includes `tmux`, `screen`, and `herdr`, so the
  outer Rex pane passes navigation keys through to a nested multiplexer.
- Removed the four default focus-key `rex.unbind` calls. Our Ctrl+h/j/k/l
  bindings are additional shortcuts; the app's default Option+Command+arrow
  shortcuts should remain available.

Updates are manual: review upstream changes at a chosen revision, replace the
copied files, reapply the local changes, and update the revision above.
