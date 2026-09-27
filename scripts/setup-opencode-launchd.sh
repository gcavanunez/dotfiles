#!/usr/bin/env bash
set -euo pipefail

LABEL=ai.opencode.service
DOMAIN="gui/$UID"
OPENCODE="$HOME/.opencode/bin/opencode"
PORT=4096
AGENT_DIR="$HOME/Library/LaunchAgents"
PLIST="$AGENT_DIR/$LABEL.plist"
LOG_DIR="$HOME/Library/Logs/OpenCode"

if [[ $(uname -s) != Darwin ]]; then
  echo "This setup script only supports macOS." >&2
  exit 1
fi

if [[ ! -x "$OPENCODE" ]] || ! "$OPENCODE" --version &>/dev/null; then
  echo "The official OpenCode V2 binary is not runnable at $OPENCODE." >&2
  echo "Install it with: curl -fsSL https://opencode.ai/v2/install | bash" >&2
  exit 1
fi

if [[ ! -f "$HOME/.config/opencode/service.json" ]]; then
  echo "OpenCode service configuration is missing." >&2
  exit 1
fi

mkdir -p "$AGENT_DIR" "$LOG_DIR"
tmp=$(mktemp "$AGENT_DIR/$LABEL.plist.XXXXXX")
trap 'rm -f "$tmp"' EXIT

cat > "$tmp" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$LABEL</string>
  <key>ProgramArguments</key>
  <array>
    <string>$OPENCODE</string>
    <string>serve</string>
    <string>--service</string>
    <string>--port</string>
    <string>$PORT</string>
  </array>
  <key>WorkingDirectory</key>
  <string>$HOME</string>
  <key>EnvironmentVariables</key>
  <dict>
    <key>PATH</key>
    <string>$HOME/.opencode/bin:$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin</string>
  </dict>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
  <key>ProcessType</key>
  <string>Interactive</string>
  <key>StandardOutPath</key>
  <string>$LOG_DIR/service.log</string>
  <key>StandardErrorPath</key>
  <string>$LOG_DIR/service.error.log</string>
</dict>
</plist>
PLIST

plutil -lint "$tmp" >/dev/null
if [[ -f "$PLIST" ]] && cmp -s "$tmp" "$PLIST" && launchctl print "$DOMAIN/$LABEL" &>/dev/null; then
  "$OPENCODE" service status
  launchctl print "$DOMAIN/$LABEL" | sed -n '/state =/p;/pid =/p'
  exit 0
fi

old_pid=$(python3 - "$HOME/.local/state/opencode/service.json" <<'PY'
import json
import sys

try:
    with open(sys.argv[1]) as state:
        print(json.load(state)["pid"])
except (KeyError, OSError, ValueError):
    pass
PY
)
launchctl bootout "$DOMAIN/$LABEL" 2>/dev/null || true
mv "$tmp" "$PLIST"
chmod 600 "$PLIST"
launchctl bootstrap "$DOMAIN" "$PLIST"
launchctl enable "$DOMAIN/$LABEL"
launchctl kickstart -k "$DOMAIN/$LABEL"

for _ in {1..100}; do
  status=$("$OPENCODE" service status 2>/dev/null || true)
  if [[ $status == "http://0.0.0.0:$PORT" || $status == "http://127.0.0.1:$PORT" ]]; then
    new_pid=$(python3 - "$HOME/.local/state/opencode/service.json" <<'PY'
import json
import sys

try:
    with open(sys.argv[1]) as state:
        print(json.load(state)["pid"])
except (KeyError, OSError, ValueError):
    pass
PY
)
    if [[ $old_pid =~ ^[1-9][0-9]*$ && $new_pid != "$old_pid" ]]; then
      kill "$old_pid" 2>/dev/null || true
    fi
    "$OPENCODE" service status
    launchctl print "$DOMAIN/$LABEL" | sed -n '/state =/p;/pid =/p'
    exit 0
  fi
  sleep 0.1
done

echo "OpenCode did not become ready. Check $LOG_DIR/service.error.log." >&2
exit 1
