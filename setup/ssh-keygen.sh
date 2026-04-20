#!/usr/bin/env bash
set -euo pipefail

# Generate an Ed25519 SSH key and add it to the agent.
# Usage: bash setup/ssh-keygen.sh [email]

KEY_FILE="$HOME/.ssh/id_ed25519"
EMAIL="${1:-}"

if [[ -z "$EMAIL" ]]; then
  read -rp "Email address (for key comment): " EMAIL
fi

if [[ -z "$EMAIL" ]]; then
  echo "Error: email is required." >&2
  exit 1
fi

# Check for existing key
if [[ -f "$KEY_FILE" ]]; then
  echo "SSH key already exists: $KEY_FILE"
  read -rp "Overwrite? [y/N] " confirm
  if [[ "$confirm" != [yY] ]]; then
    echo "Aborted."
    exit 0
  fi
fi

# Generate key
echo "==> Generating Ed25519 SSH key..."
ssh-keygen -t ed25519 -C "$EMAIL" -f "$KEY_FILE"

# Start agent and add key
echo "==> Starting ssh-agent..."
eval "$(ssh-agent -s)"

if [[ "$(uname)" == "Darwin" ]]; then
  # macOS: configure automatic agent loading + Keychain
  mkdir -p "$HOME/.ssh"
  if ! grep -q "Host github.com" "$HOME/.ssh/config" 2>/dev/null; then
    cat >> "$HOME/.ssh/config" <<EOF

Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile $KEY_FILE
EOF
    echo "  Added github.com config to ~/.ssh/config"
  fi
  ssh-add --apple-use-keychain "$KEY_FILE"
else
  ssh-add "$KEY_FILE"
fi

# Print public key
echo ""
echo "==> Public key:"
echo ""
cat "${KEY_FILE}.pub"
echo ""
echo "==> Add this key to GitHub: Settings > SSH and GPG keys > New SSH key"
echo "==> Test with: ssh -T git@github.com"
