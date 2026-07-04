# Ultimate macOS Keyboard Configuration Setup

This README documents a macOS keyboard remapping setup built around Kanata and the Karabiner DriverKit VirtualHID services. The setup uses LaunchDaemons so the services can start automatically at boot and be managed with `launchctl`.

It is integrated with various macOS scripting APIs, including `osascript` (for Spotify, system volume, screen locking), `screencapture` (for clipboard screenshots), BetterTouchTool (BTT) trigger UUIDs, Raycast extensions, and custom Python and Bash scripts.

## Overview

The system uses three launchd services:

| Service | Label | Purpose |
|---|---|---|
| Karabiner VHID Manager | `com.example.karabiner-vhidmanager` | Activates the Karabiner virtual HID device manager needed by the driver stack. |
| Karabiner VHID Daemon | `com.example.karabiner-vhiddaemon` | Runs the Karabiner virtual HID daemon used by the virtual keyboard device layer. |
| Kanata | `com.example.kanata` | Runs the Kanata remapping engine with the configured `.kbd` file through launchd. |

The loaded service state shown by `launchctl list | grep example` indicates that the labels are registered with launchd, and entries with numeric PIDs are running processes while an entry with `-` is loaded without an active PID shown in that listing.

## Implemented Features

- **Auto-start System Services:** macOS LaunchDaemons under `/Library/LaunchDaemons/`.
- **Karabiner Virtual HID stack:** Decoupled VHID manager, VHID daemon, and Kanata launcher.
- **Persistent Service Execution:** `RunAtLoad` and `KeepAlive` keep services running.
- **Direct Configuration:** Launches Kanata with the `macos.kbd` file.
- **Service Observability:** Dedicated logs via `StandardOutPath` and `StandardErrorPath`.
- **Home Row Modifiers:** Tap-hold keys on the home row for modifiers (`Ctrl`, `Alt`, `Shift`, `Cmd/Gui`) and spacebar `Hyper` key mapping.
- **Application Launcher Layer:** Direct launching of macOS apps (Chrome, Spotify, Telegram, Ghostty, Kitty, Obsidian, Notion, passmanagers, etc.).
- **System and Media Controls:** Volume, brightness, Bluetooth power toggles, clipboard history, emoji pickers, Toothpick Bluetooth connect/disconnect, and clipboard screenshots.
- **Multitasking & OBS Scene Switching Chords:** Integrated OBS scene switching scripts and Kitty session updates.

## How the System Works on macOS

macOS uses `launchd` as the service manager, and `launchctl` is the command-line interface used to load, unload, start, stop, and inspect daemons and agents. In this setup, LaunchDaemon plist files are placed in `/Library/LaunchDaemons/`, then loaded into the `system` domain so they run as background system services.

Kanata depends on the Karabiner virtual HID components to create and control the virtual input device layer on macOS, which is why the Karabiner services must be available before Kanata can function correctly. If the Karabiner daemon is not running or permissions are missing, Kanata can fail with device-registration errors or privilege-related errors.

## Files and Paths

Typical paths used in this setup include:

- **LaunchDaemons:** `/Library/LaunchDaemons/com.example.*.plist`
- **Kanata Logs:** `/Library/Logs/Kanata/kanata.out.log` and `/Library/Logs/Kanata/kanata.err.log`
- **Kanata Binary:** `/Users/aiwithnex/.config/kanata/kanata_macos_cmd_allowed_arm64` (or similar location)
- **Kanata Config:** `/Users/aiwithnex/.config/keyboard-config/kanata/macos.kbd`
- **Helper Scripts:** `$HOME/github/dotfiles-latest/` containing sketchybar, OBS scene switchers, yabai window positions, and volume/brightness utilities.

---

## Detailed Kanata Layout Mapping (`macos.kbd`)

Kanata intercepts key events and routes them through layers, aliases, and multi-key chord shortcuts defined in the config.

### 1. Layers

#### Main Layer (`main`)
The primary layer active during typing. It implements **Home Row Modifiers** (tap-hold) and layer transition buttons:
- **Left Hand Modifiers:** `a` ➔ Control, `s` ➔ Alt, `d` ➔ Shift, `f` ➔ Command/GUI.
- **Right Hand Modifiers:** `j` ➔ Command/GUI, `k` ➔ Shift, `l` ➔ Alt, `;` ➔ Control.
- **Bottom Row Left:** `z` ➔ `Cmd+Tab`, `x` ➔ `Cmd+\``, `c` ➔ Copy, `v` ➔ Paste.
- **Bottom Row Right:** `m` ➔ Homerow macro (`Shift+Cmd+Space`).
- **Spacebar:** Tap ➔ Space, Hold ➔ **Hyper Key** (Left Shift + Left Ctrl + Left Alt + Left GUI).
- **Layer Toggles:**
  - `tab` / `ret` ➔ Hold to toggle `apps` layer.
  - `bspc` (and spacebar left mod) ➔ Hold to toggle `symb` layer.
  - `caps` ➔ Hold to toggle `navi` layer.
  - `e` ➔ Hold to toggle `syst` layer.

#### Applications Layer (`apps`)
Enables launching applications by holding `Tab` or `Return` and tapping a designated key:
- **Top Row (Q-P):** `q` ➔ Antigravity, `w` ➔ WhatsApp, `e` ➔ Chrome, `r` ➔ Reminders, `t` ➔ Telegram, `y` ➔ App Store, `u` ➔ Safari, `i` ➔ Passwords, `o` ➔ OpenWhispr, `p` ➔ Preview.
- **Home Row (A-L):** `a` ➔ Antigravity IDE, `s` ➔ Zen, `d` ➔ Calendar, `f` ➔ Finder, `g` ➔ Comet, `h` ➔ Terminal, `j` ➔ Notion, `k` ➔ Notes, `l` ➔ System Settings.
- **Bottom Row (Z-M):** `x` ➔ Claude, `c` ➔ Calculator, `v` ➔ Figma, `b` ➔ VLC, `n` ➔ Spotify, `m` ➔ Mail.

#### System Layer (`syst`)
Provides system control by holding `e` and tapping a control key:
- **Spotify Controls:** `r` ➔ Next Song, `f` ➔ Play/Pause, `c` ➔ Previous Song, `t` ➔ Seek Forward, `v` ➔ Seek Backward.
- **System Audio/Brightness:** `u` ➔ Volume Up, `j` ➔ Volume Down, `k` ➔ Brightness Up, `,` ➔ Brightness Down, `l` ➔ Screen Lock, `;` ➔ Mute Toggle.
- **Utility Actions:**
  - `y` ➔ Connect BT Fav 1, `h` ➔ Disconnect BT Fav 1.
  - `,` ➔ Connect BT Fav 2, `m` ➔ Disconnect BT Fav 2.
  - `.` ➔ Clipboard History, `'` ➔ Emoji Symbols.
  - `i` ➔ Bluetooth Off.
  - `p` ➔ Screenshot (`screencapture -ci`).

#### Symbols Layer (`symb`)
Dedicated mapping for symbols, accessibility characters, and bracket pairs to facilitate fast coding:
- **Number Row:** Shifted numbers (`!`, `@`, `#`, `$`, `%`, `^`, `&`, `*`, `(`, `)`).
- **QWERTY Row:** Base numbers (`1` to `0`), `-`.
- **Home Row:** `=`, `\`, `[`, `{`, `}`, `]`, `,`, `.`, `+`.

#### Navigation Layer (`navi`)
Re-maps the keys to high-fidelity cursor navigation when holding `Caps Lock`:
- **Arrows:** `h` ➔ Left, `j` ➔ Down, `k` ➔ Up, `l` ➔ Right.
- **Fast Navigation:**
  - `e` / `c` ➔ Cmd+Up / Shift+Cmd+Up
  - `r` / `v` ➔ Cmd+Down / Shift+Cmd+Down
  - `y` / `n` ➔ Shift+Left / Shift+Right
  - `u` / `i` / `o` / `p` ➔ Cmd+Left / Alt+Left / Alt+Right / Cmd+Right.
  - `,` / `.` ➔ Shift+Alt+Left / Shift+Alt+Right.
  - `m` ➔ Shift+Cmd+Left.
  - `(s d f)` ➔ Zoom Out (`Cmd + -`)
- **Volume Chords:**
  - `(q w e)` ➔ Volume Up (`volu`)
  - `(a s d)` ➔ Volume Down (`vold`)
- **App/WindowManager Positioning (yabai/sketchybar):**
  - `(spc t h/j/l/u/e/r)` ➔ Focus specific Kitty terminal instances (Home, Dotfiles, Blogpost, Obsidian, Kanata Private, Daily Note) and dynamically updates Sketchybar using the custom `kitty_name.sh` script.
- **OBS Scene Switching:**
  - `(spc o m)` ➔ Switches to OBS scene: `main-1-guest-live`
  - `(spc o i)` ➔ Switches to OBS scene: `guests-all-notes-right-live`
  - `(spc o a)` ➔ Switches to OBS scene: `guest1-1guest-live`
  - `(spc o n)` ➔ Switches to OBS scene: `starting-soon`
  - `(spc o c)` ➔ Switches to OBS scene: `be-right-back`
  - `(spc o k)` ➔ Switches to OBS scene: `keyboard`
  - `(spc o z/x/h)` ➔ Switches to specific Zoom OBS layouts and adjusts yabai custom padding margins.
- **Recording & Notifications:**
  - `(n o t)` ➔ Dismiss macOS notifications (via BetterTouchTool URL trigger).
  - `(s t a)` ➔ Start screen recording (via BTT trigger).
  - `(s t o)` ➔ Stop screen recording (via BTT trigger).
  - `(a s d f)` ➔ Mute/unmute microphone input via `200-micMute.sh`.

---

## Service Management

### Check Current Status

```bash
sudo launchctl list | grep example
```

This lists the loaded services matching the selected labels and helps confirm whether the daemons are currently known to launchd.

### Start Services Manually

```bash
sudo launchctl start com.example.karabiner-vhidmanager
sudo launchctl start com.example.karabiner-vhiddaemon
sudo launchctl start com.example.kanata
```

### Restart Services

For a full restart, use `bootout` to unload the plist, `bootstrap` to load it again into the system domain, and `kickstart -k` to force a relaunch of a loaded service.

```bash
sudo launchctl bootout system /Library/LaunchDaemons/com.example.karabiner-vhidmanager.plist
sudo launchctl bootstrap system /Library/LaunchDaemons/com.example.karabiner-vhidmanager.plist
sudo launchctl kickstart -k system/com.example.karabiner-vhidmanager

sudo launchctl bootout system /Library/LaunchDaemons/com.example.karabiner-vhiddaemon.plist
sudo launchctl bootstrap system /Library/LaunchDaemons/com.example.karabiner-vhiddaemon.plist
sudo launchctl kickstart -k system/com.example.karabiner-vhiddaemon

sudo launchctl bootout system /Library/LaunchDaemons/com.example.kanata.plist
sudo launchctl bootstrap system /Library/LaunchDaemons/com.example.kanata.plist
sudo launchctl kickstart -k system/com.example.kanata
```

For a quick Kanata-only restart when the service is already loaded, this is usually enough:

```bash
sudo launchctl kickstart -k system/com.example.kanata
```

### Reload Kanata After Config Changes

```bash
sudo launchctl stop com.example.kanata
sudo launchctl start com.example.kanata
```

---

## Logs

Kanata has two explicit log files when `StandardOutPath` and `StandardErrorPath` are configured in the plist.

### Normal Output Log

```bash
sudo tail -f /Library/Logs/Kanata/kanata.out.log
```

This shows standard output such as normal runtime messages and startup output when the process writes to stdout.

### Error Log

```bash
sudo tail -f /Library/Logs/Kanata/kanata.err.log
```

This shows standard error output such as warnings, crashes, and other runtime errors.

### Unified macOS Logs

macOS also provides unified logging, which can be queried or streamed with the `log` command or viewed in Console.app.

```bash
log show --predicate 'process == "kanata"' --last 1h
log stream --predicate 'process == "kanata"'
log show --predicate 'process == "Karabiner-VirtualHIDDevice-Daemon"' --last 1h
log stream --predicate 'process == "Karabiner-VirtualHIDDevice-Daemon"'
```

---

## Common Issues

| Issue | Likely cause | Action |
|---|---|---|
| `IOHIDDeviceOpen error: privilege violation` | Missing permissions or incorrect execution context | Ensure the required accessibility and input monitoring permissions are granted to the Kanata binary. |
| `Couldn't register any device` | Karabiner daemon not running or permissions missing | Start the Karabiner services first and verify permissions. |
| `driver_version_mismatched` | Kanata version incompatible with installed Karabiner driver | Match compatible Kanata and Karabiner driver versions. |
| Repeated crash or unusual exit status | Invalid path, permissions, or config issue | Verify plist paths, log files, and config correctness. |

---

## System Integration Scripting APIs

### 1. Spotify Command-line Controls (AppleScript)

```bash
# Play / pause
osascript -e 'tell application "Spotify" to playpause'

# Next song
osascript -e 'tell application "Spotify" to next track'

# Previous song
osascript -e 'tell application "Spotify" to previous track'

# Forward 10 seconds
osascript -e 'tell application "Spotify" to set player position to (player position + 10)'

# Backward 10 seconds
osascript -e 'tell application "Spotify" to set player position to (player position - 10)'
```

### 2. Native Interactive Screenshot

```bash
# Interactive area capture saved directly to clipboard
screencapture -ci
```

### 3. Display Brightness & System Sound

```bash
# Brightness up (Sends virtual Key Code 144)
osascript -e 'tell application "System Events" to key code 144'

# Brightness down (Sends virtual Key Code 145)
osascript -e 'tell application "System Events" to key code 145'

# Mute audio toggle
osascript -e 'set volume output muted (not (output muted of (get volume settings)))'
```
