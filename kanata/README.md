# Ultimate macOS Keyboard Configuration Setup

This README documents a comprehensive keyboard remapping setup for macOS. By leveraging Kanata and the Karabiner DriverKit VirtualHID services, this setup transforms a standard keyboard into a highly productive tool. It introduces advanced concepts like Home Row Modifiers and multiple custom layers for launching applications, controlling system media, accessing symbols, and performing fast navigation—all designed to minimize hand movement and maximize efficiency.

## Startup Configuration

To ensure the custom keyboard layers are always available, this system is configured to start automatically at boot. This is achieved using macOS LaunchDaemons. Three background services are loaded into the system domain and managed by `launchctl`:
1. **Karabiner Virtual HID Manager:** Manages the virtual device stack.
2. **Karabiner Virtual HID Daemon:** Runs the virtual keyboard device layer.
3. **Kanata:** The remapping engine that interprets the custom layout configuration.

These services run persistently in the background, providing a seamless experience from the moment the system starts without requiring any manual intervention.

## Key Bindings & Layers

Kanata intercepts key events and routes them through specialized layers, aliases, and multi-key chord shortcuts.

### Main Layer (`main`)
The primary layer active during typing, implementing **Home Row Modifiers** (tap-hold) and layer transition buttons:

- **Left Hand Modifiers:** `a` (Control), `s` (Alt), `d` (Shift), `f` (Command/GUI)
- **Right Hand Modifiers:** `j` (Command/GUI), `k` (Shift), `l` (Alt), `;` (Control)
- **Bottom Row Left:** `z` (`Cmd+Tab`), `x` (`Cmd+\``), `c` (Copy), `v` (Paste)
- **Bottom Row Right:** `m` (Homerow macro: `Shift+Cmd+Space`)
- **Spacebar:** Tap (Space), Hold (**Hyper Key**: LShift + LCtrl + LAlt + LGUI)

**Layer Toggles:**
- Hold `tab` / `ret` ➔ `apps` layer
- Hold `bspc` (or spacebar left mod) ➔ `symb` layer
- Hold `caps` ➔ `navi` layer
- Hold `e` ➔ `syst` layer

### Applications Layer (`apps`)
Triggered by holding `Tab` or `Return`. Enables quick application launching:

| Top Row (Q-P) | Home Row (A-L) | Bottom Row (Z-M) |
| :--- | :--- | :--- |
| `q` - Antigravity | `a` - Antigravity IDE | `x` - Claude |
| `w` - WhatsApp | `s` - Zen | `c` - Calculator |
| `e` - Chrome | `d` - Calendar | `v` - Figma |
| `r` - Reminders | `f` - Finder | `b` - VLC |
| `t` - Telegram | `g` - Comet | `n` - Spotify |
| `y` - App Store | `h` - Terminal | `m` - Mail |
| `u` - Safari | `j` - Notion | |
| `i` - Passwords | `k` - Notes | |
| `o` - OpenWhispr | `l` - System Settings| |
| `p` - Preview | | |

### System Layer (`syst`)
Triggered by holding `e`. Provides media, brightness, and utility controls:

- **Media:** `r` (Next), `f` (Play/Pause), `c` (Previous), `t` (Seek Fwd), `v` (Seek Bwd)
- **Audio/Display:** `u` (Vol Up), `j` (Vol Down), `;` (Mute Toggle), `k` (Bright Up), `,` (Bright Down)
- **Utilities:**
  - `l` (Screen Lock), `i` (Bluetooth Off)
  - `y` / `h` (Connect/Disconnect BT Fav 1)
  - `,` / `m` (Connect/Disconnect BT Fav 2)
  - `.` (Clipboard History), `'` (Emoji Symbols)
  - `p` (Interactive Screenshot)

### Symbols Layer (`symb`)
Triggered by holding `Backspace`. Dedicated mapping for symbols and brackets:

- **Number Row:** `!`, `@`, `#`, `$`, `%`, `^`, `&`, `*`, `(`, `)`
- **QWERTY Row:** `1` to `0`, `-`
- **Home Row:** `=`, `\`, `[`, `{`, `}`, `]`, `,`, `.`, `+`

### Navigation Layer (`navi`)
Triggered by holding `Caps Lock`. High-fidelity cursor navigation and window management:

- **Arrows:** `h` (Left), `j` (Down), `k` (Up), `l` (Right)
- **Fast Navigation:**
  - `e` / `c` ➔ Cmd+Up / Shift+Cmd+Up
  - `r` / `v` ➔ Cmd+Down / Shift+Cmd+Down
  - `y` / `n` ➔ Shift+Left / Shift+Right
  - `u` / `i` / `o` / `p` ➔ Cmd+Left / Alt+Left / Alt+Right / Cmd+Right
  - `,` / `.` ➔ Shift+Alt+Left / Shift+Alt+Right
  - `m` ➔ Shift+Cmd+Left
- **Chords:**
  - `(s d f)` ➔ Zoom Out
  - `(q w e)` / `(a s d)` ➔ Volume Up / Down
  - `(n o t)` ➔ Dismiss Notifications
  - `(s t a)` / `(s t o)` ➔ Start / Stop Screen Recording
  - `(a s d f)` ➔ Mute/Unmute Mic
- **OBS Scene Switching:**
  - `(spc o m)` ➔ `main-1-guest-live`
  - `(spc o i)` ➔ `guests-all-notes-right-live`
  - `(spc o a)` ➔ `guest1-1guest-live`
  - `(spc o n)` ➔ `starting-soon`
  - `(spc o c)` ➔ `be-right-back`
  - `(spc o k)` ➔ `keyboard`
  - `(spc o z/x/h)` ➔ Zoom layouts

---

## Implementation Details

### How the System Works on macOS

macOS uses `launchd` as the service manager, and `launchctl` is the command-line interface used to load, unload, start, stop, and inspect daemons and agents. LaunchDaemon plist files are placed in `/Library/LaunchDaemons/`, loaded into the `system` domain, and set to `RunAtLoad` and `KeepAlive`.

Kanata depends on the Karabiner virtual HID components to create and control the virtual input device layer on macOS. If the Karabiner daemon is not running or permissions are missing, Kanata will fail with device-registration errors.

### Files and Paths

- **LaunchDaemons:** `/Library/LaunchDaemons/com.example.*.plist`
- **Kanata Logs:** `/Library/Logs/Kanata/kanata.out.log` and `/Library/Logs/Kanata/kanata.err.log`
- **Kanata Binary:** `/Users/aiwithnex/.config/kanata/kanata_macos_cmd_allowed_arm64`
- **Kanata Config:** `/Users/aiwithnex/.config/keyboard-config/kanata/macos.kbd`
- **Helper Scripts:** `$HOME/github/dotfiles-latest/`

### Service Management

**Check current status:**
```bash
sudo launchctl list | grep example
```

**Restart Kanata after config changes:**
```bash
sudo launchctl kickstart -k system/com.example.kanata
```

**Full reload of all services:**
```bash
sudo launchctl bootout system /Library/LaunchDaemons/com.example.kanata.plist
sudo launchctl bootstrap system /Library/LaunchDaemons/com.example.kanata.plist
sudo launchctl kickstart -k system/com.example.kanata
# Repeat the above commands for Karabiner Manager and Daemon
```

### Logs

Kanata has two explicit log files when `StandardOutPath` and `StandardErrorPath` are configured in the plist.
- **Normal Output Log:** `sudo tail -f /Library/Logs/Kanata/kanata.out.log`
- **Error Log:** `sudo tail -f /Library/Logs/Kanata/kanata.err.log`

### Common Issues

| Issue | Likely cause | Action |
|---|---|---|
| `IOHIDDeviceOpen error: privilege violation` | Missing permissions or incorrect execution context | Ensure required accessibility/input monitoring permissions are granted to the Kanata binary. |
| `Couldn't register any device` | Karabiner daemon not running or permissions missing | Start Karabiner services first and verify permissions. |
| `driver_version_mismatched` | Kanata version incompatible with installed Karabiner driver | Match compatible Kanata and Karabiner driver versions. |
