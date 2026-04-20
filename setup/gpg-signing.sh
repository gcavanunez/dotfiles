#!/usr/bin/env bash
set -euo pipefail

# Set up GPG commit signing for Git.
# Usage: bash setup/gpg-signing.sh [email]
#
# What this script does:
#   1. Installs GPG if missing (brew on macOS, apt on Linux)
#   2. Generates a 4096-bit RSA GPG key (if none exists for the email)
#   3. Configures Git to sign all commits and tags
#   4. Adds GPG_TTY to your shell config
#   5. Configures pinentry-mac on macOS
#   6. Prints the public key for adding to GitHub

EMAIL="${1:-}"

if [[ -z "$EMAIL" ]]; then
  read -rp "Email address (must match your GitHub account): " EMAIL
fi

if [[ -z "$EMAIL" ]]; then
  echo "Error: email is required." >&2
  exit 1
fi

OS="$(uname)"

# --- Install GPG if needed ---
if ! command -v gpg &>/dev/null; then
  echo "==> Installing GPG..."
  if [[ "$OS" == "Darwin" ]]; then
    brew install gnupg
  else
    sudo apt-get update -qq && sudo apt-get install -y gnupg
  fi
fi

# --- Check for existing key ---
EXISTING_KEY=$(gpg --list-secret-keys --keyid-format=long "$EMAIL" 2>/dev/null \
  | grep "^sec" | head -1 | sed 's|.*/\([A-F0-9]*\) .*|\1|' || true)

if [[ -n "$EXISTING_KEY" ]]; then
  echo "==> Found existing GPG key for $EMAIL: $EXISTING_KEY"
  KEY_ID="$EXISTING_KEY"
else
  echo "==> Generating new GPG key for $EMAIL..."

  # Generate key using unattended mode
  gpg --batch --gen-key <<EOF
%no-protection
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: $(git config --global user.name || echo "$USER")
Name-Email: $EMAIL
Expire-Date: 0
%commit
EOF

  KEY_ID=$(gpg --list-secret-keys --keyid-format=long "$EMAIL" 2>/dev/null \
    | grep "^sec" | head -1 | sed 's|.*/\([A-F0-9]*\) .*|\1|')

  if [[ -z "$KEY_ID" ]]; then
    echo "Error: failed to generate GPG key." >&2
    exit 1
  fi

  echo "  Generated key: $KEY_ID"
  echo ""
  echo "  NOTE: The key was generated without a passphrase for automation."
  echo "  To add a passphrase later, run: gpg --edit-key $KEY_ID passwd"
fi

# --- Configure Git ---
echo "==> Configuring Git to sign commits..."
git config --global user.signingkey "$KEY_ID"
git config --global commit.gpgsign true
git config --global tag.gpgSign true
echo "  Set user.signingkey=$KEY_ID"
echo "  Enabled commit.gpgsign and tag.gpgSign"

# --- GPG_TTY in shell config ---
echo "==> Configuring GPG_TTY..."

add_gpg_tty() {
  local rcfile="$1"
  if [[ -f "$rcfile" ]] && ! grep -q "GPG_TTY" "$rcfile"; then
    echo "" >> "$rcfile"
    echo "# GPG signing" >> "$rcfile"
    echo 'export GPG_TTY=$(tty)' >> "$rcfile"
    echo "  Added GPG_TTY to $rcfile"
  elif [[ -f "$rcfile" ]]; then
    echo "  GPG_TTY already set in $rcfile"
  fi
}

add_gpg_tty "$HOME/.zshrc"
add_gpg_tty "$HOME/.bashrc"

# --- pinentry-mac (macOS only) ---
if [[ "$OS" == "Darwin" ]]; then
  echo "==> Configuring pinentry-mac..."
  if ! command -v pinentry-mac &>/dev/null; then
    brew install pinentry-mac
  fi
  mkdir -p "$HOME/.gnupg"
  if ! grep -q "pinentry-program" "$HOME/.gnupg/gpg-agent.conf" 2>/dev/null; then
    echo "pinentry-program $(which pinentry-mac)" >> "$HOME/.gnupg/gpg-agent.conf"
    echo "  Configured pinentry-mac in gpg-agent.conf"
  fi
  gpgconf --kill gpg-agent
fi

# --- Print public key ---
echo ""
echo "==> Public key (add this to GitHub > Settings > SSH and GPG keys > New GPG key):"
echo ""
gpg --armor --export "$KEY_ID"
echo ""
echo "==> Done! Add the key above to GitHub, then verify with:"
echo "     git commit --allow-empty -S -m 'test: verify gpg signing'"
