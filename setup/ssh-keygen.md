# SSH Key Generation

Generate an Ed25519 SSH key for GitHub authentication.

## Prerequisites

- OpenSSH installed (pre-installed on macOS and most Linux distros)

## Step by step

### 1. Check for existing keys

```bash
ls -la ~/.ssh/id_ed25519*
```

If files exist, you can skip to step 3 (or generate a new key with a different filename).

### 2. Generate a new key

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

When prompted:
- **File**: press Enter to accept the default (`~/.ssh/id_ed25519`)
- **Passphrase**: enter a secure passphrase (recommended) or press Enter for none

### 3. Start the SSH agent

#### macOS

```bash
eval "$(ssh-agent -s)"
```

If you're using macOS Sierra 10.12.2 or later, add this to `~/.ssh/config` so the
key is automatically loaded and the passphrase stored in Keychain:

```
Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
```

Then add the key:

```bash
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

#### Linux

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

### 4. Add the public key to GitHub

Copy the public key to your clipboard:

```bash
# macOS
pbcopy < ~/.ssh/id_ed25519.pub

# Linux (requires xclip)
xclip -selection clipboard < ~/.ssh/id_ed25519.pub

# or just print it and copy manually
cat ~/.ssh/id_ed25519.pub
```

Then go to **GitHub > Settings > SSH and GPG keys > New SSH key**, paste the key, and save.

### 5. Test the connection

```bash
ssh -T git@github.com
```

You should see: `Hi <username>! You've successfully authenticated...`

## Automation

Run the included script to automate steps 1-3:

```bash
bash setup/ssh-keygen.sh
```

## References

- https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
