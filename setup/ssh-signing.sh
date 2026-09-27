#!/usr/bin/env bash
set -euo pipefail

# Opt-in SSH commit signing for this machine.
# Usage: bash setup/ssh-signing.sh [public-key]   (default: ~/.ssh/id_ed25519.pub)
#
# Each machine signs with its own passphrase-less key, so signing keeps working
# after a reboot without unlocking anything; disk encryption and the login are
# the lock. If a machine is lost, delete just its key on GitHub.
#
# What this script does:
#   1. Creates the key if it does not exist
#   2. Adds it to ~/.config/git/allowed_signers for local verification
#   3. Configures Git (global) to sign commits and tags with it
#   4. Registers it on GitHub as a signing key with gh

KEY="${1:-$HOME/.ssh/id_ed25519.pub}"
PRIVATE_KEY="${KEY%.pub}"
EMAIL=$(git config --global user.email || true)

if [[ -z "$EMAIL" ]]; then
  echo "Set git user.email first: git config --global user.email you@example.com" >&2
  exit 1
fi

if [[ ! -f "$PRIVATE_KEY" ]]; then
  echo "==> Creating $PRIVATE_KEY..."
  mkdir -p "$(dirname "$PRIVATE_KEY")"
  ssh-keygen -t ed25519 -N "" -C "$EMAIL $(hostname -s)" -f "$PRIVATE_KEY"
fi

if ! ssh-keygen -y -P "" -f "$PRIVATE_KEY" &>/dev/null; then
  echo "$PRIVATE_KEY has a passphrase, so signing would prompt after every reboot." >&2
  echo "Pick a passphrase-less key, or remove it with: ssh-keygen -p -N \"\" -f $PRIVATE_KEY" >&2
  exit 1
fi

ALLOWED_SIGNERS="$HOME/.config/git/allowed_signers"
mkdir -p "$(dirname "$ALLOWED_SIGNERS")"
signer="$EMAIL $(cut -d' ' -f1,2 "$KEY")"
if ! grep -Fqx "$signer" "$ALLOWED_SIGNERS" 2>/dev/null; then
  echo "$signer" >> "$ALLOWED_SIGNERS"
fi

git config --global gpg.format ssh
git config --global user.signingkey "$KEY"
git config --global gpg.ssh.allowedSignersFile "$ALLOWED_SIGNERS"
git config --global commit.gpgsign true
git config --global tag.gpgSign true
echo "==> Git signs commits and tags with $KEY"

if command -v gh &>/dev/null; then
  if output=$(gh ssh-key add "$KEY" --type signing --title "$(hostname -s) signing" 2>&1); then
    echo "==> Registered $KEY as a GitHub signing key"
  elif grep -qi "already" <<< "$output"; then
    echo "==> $KEY is already a GitHub signing key"
  else
    echo "$output" >&2
    echo "Grant gh the scope and rerun: gh auth refresh -h github.com -s admin:ssh_signing_key" >&2
    exit 1
  fi
else
  echo "Add $KEY on GitHub as a signing key: https://github.com/settings/ssh/new"
fi
