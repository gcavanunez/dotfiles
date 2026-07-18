#!/usr/bin/env bash
set -euo pipefail

DOTFILES=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
UNIT_SOURCE="$DOTFILES/systemd/user/opencode.service"
UNIT_DIR="$HOME/.config/systemd/user"
ENV_DIR="$HOME/.config/opencode"
ENV_FILE="$ENV_DIR/server.env"

if [[ ! -f "$UNIT_SOURCE" ]]; then
  echo "Missing service unit: $UNIT_SOURCE" >&2
  exit 1
fi

if [[ ! -x "$HOME/.opencode/bin/opencode" ]] && ! command -v opencode &>/dev/null; then
  echo "opencode not found. Install it first with: curl -fsSL https://opencode.ai/install | bash" >&2
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

mkdir -p "$UNIT_DIR" "$ENV_DIR"
ln -sf "$UNIT_SOURCE" "$UNIT_DIR/opencode.service"

if [[ -n "${OPENCODE_SERVER_PASSWORD:-}" ]]; then
  umask 077
  printf 'OPENCODE_SERVER_PASSWORD=%q\n' "$OPENCODE_SERVER_PASSWORD" > "$ENV_FILE"
elif [[ ! -f "$ENV_FILE" ]]; then
  read -rsp "OpenCode server password: " password
  printf '\n'
  if [[ -z "$password" ]]; then
    echo "Password cannot be empty." >&2
    exit 1
  fi
  umask 077
  printf 'OPENCODE_SERVER_PASSWORD=%q\n' "$password" > "$ENV_FILE"
fi

chmod 600 "$ENV_FILE"
systemctl --user daemon-reload

if ! systemd-run --user --wait --collect --quiet --property=Type=oneshot "$docker_bin" info >/dev/null 2>&1; then
  echo "Docker is not reachable from user systemd." >&2
  echo "Make sure Docker is running and your user is in the docker group, then log out and back in." >&2
  exit 1
fi

echo "Docker access from user systemd: ok"
systemctl --user enable --now opencode.service
systemctl --user restart opencode.service
systemctl --user --no-pager --full status opencode.service
