#!/usr/bin/env bash
set -euo pipefail

DOTFILES=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
UNIT_SOURCE="$DOTFILES/systemd/user/opencode.service"
SERVER_SOURCE="$DOTFILES/scripts/opencode-systemd-serve"
UNIT_DIR="$HOME/.config/systemd/user"
ENV_DIR="$HOME/.config/opencode"
ENV_FILE="$ENV_DIR/server.env"
OPENCODE="$HOME/.opencode/bin/opencode"

if [[ ! -f "$UNIT_SOURCE" ]]; then
  echo "Missing service unit: $UNIT_SOURCE" >&2
  exit 1
fi

if [[ ! -x "$SERVER_SOURCE" ]]; then
  echo "Missing service launcher: $SERVER_SOURCE" >&2
  exit 1
fi

if [[ ! -x "$OPENCODE" ]] || ! "$OPENCODE" --version &>/dev/null; then
  echo "The official OpenCode V2 binary is not runnable at $OPENCODE." >&2
  echo "Install it with: curl -fsSL https://opencode.ai/v2/install | bash" >&2
  exit 1
fi

if ! command -v systemctl &>/dev/null; then
  echo "systemctl not found." >&2
  exit 1
fi

docker_bin=$(command -v docker || true)
if [[ -z "$docker_bin" ]]; then
  echo "docker not found. Install Docker first: https://docs.docker.com/engine/install/" >&2
  exit 1
fi

mkdir -p "$UNIT_DIR" "$ENV_DIR" "$HOME/.local/bin"
ln -sf "$UNIT_SOURCE" "$UNIT_DIR/opencode.service"
ln -sf "$SERVER_SOURCE" "$HOME/.local/bin/opencode-systemd-serve"

write_server_password() {
  local password=$1
  local tmp

  tmp=$(mktemp "$ENV_DIR/server.env.XXXXXX")
  if [[ -f "$ENV_FILE" ]]; then
    awk '!/^OPENCODE_SERVER_PASSWORD=/' "$ENV_FILE" > "$tmp"
  fi
  printf 'OPENCODE_SERVER_PASSWORD=%q\n' "$password" >> "$tmp"
  chmod 600 "$tmp"
  mv "$tmp" "$ENV_FILE"
}

if [[ -n "${OPENCODE_SERVER_PASSWORD:-}" ]]; then
  write_server_password "$OPENCODE_SERVER_PASSWORD"
elif [[ ! -f "$ENV_FILE" ]] || ! grep -q '^OPENCODE_SERVER_PASSWORD=' "$ENV_FILE"; then
  read -rsp "OpenCode server password: " password
  printf '\n'
  if [[ -z "$password" ]]; then
    echo "Password cannot be empty." >&2
    exit 1
  fi
  write_server_password "$password"
fi

chmod 600 "$ENV_FILE"
systemctl --user daemon-reload

if ! systemd-run --user --wait --collect --quiet --property=Type=oneshot "$docker_bin" info >/dev/null 2>&1; then
  echo "Docker is not reachable from user systemd." >&2
  echo "Make sure Docker is running and your user is in the docker group, then log out and back in." >&2
  exit 1
fi

echo "Docker access from user systemd: ok"
# Linger starts the user's systemd instance at boot, so OpenCode runs without a login.
if [[ $(loginctl show-user "$USER" -p Linger --value 2>/dev/null) != yes ]]; then
  echo "Enabling linger so OpenCode starts at boot..."
  sudo loginctl enable-linger "$USER"
fi

systemctl --user enable --now opencode.service
systemctl --user restart opencode.service
sleep 1
if ! systemctl --user is-active --quiet opencode.service; then
  systemctl --user --no-pager --full status opencode.service || true
  exit 1
fi

systemctl --user show opencode.service -p ActiveState -p MainPID --no-pager
