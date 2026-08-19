# Omarchy Dotfiles

Omarchy-only configuration that is not installed by the top-level dotfiles
installer.

## Closed-lid use

Install the CLI, Hyprland lid handler, and systemd-logind policy explicitly on
an Omarchy machine:

```bash
~/dotfiles/omarchy/install
```

The installer symlinks the CLI, copies the Hyprland configuration and tracked
logind policy into place, and does not modify Omarchy's managed files under
`~/.local/share/omarchy`.

Reboot after installation, then control AC-powered closed-lid behavior with:

```bash
omarchy-lid on
omarchy-lid off
omarchy-lid toggle
omarchy-lid status
```

Battery-powered lid closes always suspend. The mode only controls lid closes
on external power and defaults to off until explicitly enabled.
