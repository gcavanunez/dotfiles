# macOS Setup Notes

Manual macOS preferences and direct-installer apps that are not owned by Homebrew
or mise.

## Direct Installer Apps

### Karabiner-Elements

Install from the official download instead of Homebrew cask:

https://karabiner-elements.pqrs.org/

Optional config location if we decide to manage it later:

```text
~/.config/karabiner/karabiner.json
```

## Window Management

### Move Windows With Ctrl + Cmd + Drag

Enable dragging windows from anywhere in the window while holding Ctrl + Cmd:

```bash
defaults write -g NSWindowShouldDragOnGesture -bool true
```

Restart affected apps, or log out and back in.

To disable:

```bash
defaults delete -g NSWindowShouldDragOnGesture
```

## Trackpad Gestures

### App Expose With Three-Finger Swipe Down

Configure through System Settings:

```text
System Settings > Trackpad > More Gestures > App Expose
```

Set it to:

```text
Swipe Down with Three Fingers
```

This shows all windows for the current app.

I am keeping this one manual for now because the defaults keys for trackpad
gestures vary across macOS versions and built-in vs external trackpads.
