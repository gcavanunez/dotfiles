#!/usr/bin/env bash
set -euo pipefail

DOTFILES=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
UNIT_SOURCE="$DOTFILES/systemd/user/mailplug.service"
UNIT_DIR="$HOME/.config/systemd/user"
MAILPLUG="$HOME/.bun/bin/mailplug"

if [[ ! -x "$MAILPLUG" ]]; then
  echo "mailplug is not linked at $MAILPLUG." >&2
  echo "From the mailplug checkout: bun install && (cd packages/cli && bun link)" >&2
  exit 1
fi

mkdir -p "$UNIT_DIR"
ln -sf "$UNIT_SOURCE" "$UNIT_DIR/mailplug.service"

# A service started by a CLI command outside systemd would hold the port; hand over to systemd.
"$MAILPLUG" service stop >/dev/null 2>&1 || true

systemctl --user daemon-reload

# Linger starts the user's systemd instance at boot, so mail syncs without a login.
if [[ $(loginctl show-user "$USER" -p Linger --value 2>/dev/null) != yes ]]; then
  echo "Enabling linger so mailplug starts at boot..."
  sudo loginctl enable-linger "$USER"
fi

systemctl --user enable --now mailplug.service
sleep 1
if ! systemctl --user is-active --quiet mailplug.service; then
  systemctl --user --no-pager --full status mailplug.service || true
  exit 1
fi

"$MAILPLUG" service status
