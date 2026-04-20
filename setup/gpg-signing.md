# GPG Signed Commits

Set up GPG key generation and configure Git to sign all commits automatically.

## Prerequisites

#### macOS

```bash
brew install gnupg pinentry-mac
```

#### Linux (Debian/Ubuntu)

```bash
sudo apt-get install -y gnupg
```

## Step by step

### 1. Check for existing GPG keys

```bash
gpg --list-secret-keys --keyid-format=long
```

If you see a key with your email, skip to step 3.

### 2. Generate a new GPG key

```bash
gpg --full-generate-key
```

When prompted:
- **Key type**: RSA and RSA (default)
- **Key size**: `4096`
- **Expiration**: `0` (no expiry) or set your preference
- **Name**: your full name
- **Email**: the email on your GitHub account (use your `noreply` address to keep it private)
- **Passphrase**: enter a secure passphrase

### 3. Get your GPG key ID

```bash
gpg --list-secret-keys --keyid-format=long
```

Output looks like:

```
sec   rsa4096/3AA5C34371567BD2 2024-01-01 [SC]
      ABCDEF1234567890ABCDEF1234567890ABCDEF12
uid                 [ultimate] Your Name <your_email@example.com>
ssb   rsa4096/4BB6D45482678BE3 2024-01-01 [E]
```

The key ID is the part after `rsa4096/` on the `sec` line — in this example: `3AA5C34371567BD2`.

### 4. Configure Git to use your GPG key

```bash
git config --global user.signingkey 3AA5C34371567BD2
git config --global commit.gpgsign true
git config --global tag.gpgSign true
```

### 5. Set GPG_TTY in your shell

This is required for GPG to prompt for your passphrase in the terminal.

#### zsh (add to ~/.zshrc)

```bash
export GPG_TTY=$(tty)
```

#### bash (add to ~/.bashrc)

```bash
export GPG_TTY=$(tty)
```

### 6. Configure pinentry (macOS only)

```bash
mkdir -p ~/.gnupg
echo "pinentry-program $(which pinentry-mac)" >> ~/.gnupg/gpg-agent.conf
gpgconf --kill gpg-agent
```

### 7. Export and add the public key to GitHub

```bash
gpg --armor --export 3AA5C34371567BD2
```

Copy the entire output (including the `-----BEGIN PGP PUBLIC KEY BLOCK-----` and
`-----END PGP PUBLIC KEY BLOCK-----` lines).

Go to **GitHub > Settings > SSH and GPG keys > New GPG key**, paste the key, and save.

### 8. Verify it works

```bash
# Make a signed commit
git commit --allow-empty -S -m "test: verify gpg signing"

# Verify the signature
git log --show-signature -1
```

## Automation

Run the included script to automate steps 1-6:

```bash
bash setup/gpg-signing.sh
```

The script will generate a key (if needed), configure Git, and set up your shell.
You still need to manually add the public key to GitHub (step 7).

## Troubleshooting

**"gpg: signing failed: Inappropriate ioctl for device"**
Ensure `export GPG_TTY=$(tty)` is in your shell config and reload your shell.

**"gpg: signing failed: No secret key"**
Check that `user.signingkey` in your gitconfig matches the key ID from `gpg --list-secret-keys --keyid-format=long`.

**Passphrase prompt not appearing (macOS)**
Install `pinentry-mac` and configure it per step 6.

## References

- https://docs.github.com/en/authentication/managing-commit-signature-verification
- https://docs.github.com/en/authentication/managing-commit-signature-verification/generating-a-new-gpg-key
- https://docs.github.com/en/authentication/managing-commit-signature-verification/telling-git-about-your-signing-key
