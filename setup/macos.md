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

## Finder

### Show the Path Bar and Status Bar

```bash
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
killall Finder
```

### Show External and Removable Volumes on the Desktop

Keep internal hard drives hidden while showing external drives and removable
media:

```bash
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
killall Finder
```

### Prefer Icon View

```bash
defaults write com.apple.finder FXPreferredViewStyle -string "icnv"
killall Finder
```

## Pointer and Scrolling

These are the current pointer and scrolling speeds. The System Settings sliders
do not display their numeric values.

```bash
defaults write -g com.apple.trackpad.scaling -float 2.5
defaults write -g com.apple.trackpad.scrolling -float 0.4412
defaults write -g com.apple.scrollwheel.scaling -float 0.4412
```

### Tap to Click and Force Click

Enable tap to click for built-in and Bluetooth trackpads, and disable Force
Click:

```bash
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write -currentHost -g com.apple.mouse.tapBehavior -int 1
defaults write -g com.apple.trackpad.forceClick -bool false
```

Log out and back in after changing trackpad preferences.

## Screenshots

### Save Screenshots in Documents

```bash
mkdir -p "$HOME/Documents/screenshots"
defaults write com.apple.screencapture location -string "$HOME/Documents/screenshots"
killall SystemUIServer
```

### Copy a Selected Area With Shift + Cmd + S

Configure this through System Settings rather than editing the nested symbolic
hotkey preferences directly:

```text
System Settings > Keyboard > Keyboard Shortcuts > Screenshots
```

Set `Copy picture of selected area to the clipboard` to `Shift + Cmd + S`.
