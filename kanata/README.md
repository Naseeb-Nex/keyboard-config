# Kanata Setup and Operations Guide

## ⚠️ Important Setup Details
- **Custom Binary**: Uses `kanata_macos_cmd_allowed_arm64` to allow executing commands (e.g., app launching).
- **Karabiner Virtual HID Device Driver**: *MUST* be installed and running *before* Kanata to intercept keyboard inputs without privilege issues.
- **Custom Mapping**: The `apps` layer replaces Antigravity IDE with **Orca** on the `a` key.
- **Folder Structure**: 
  - `launchd/` stores auto-start configuration plists.
  - `utilities/` stores helper scripts like `restart_kanata.sh`.

---

## Auto-Start with LaunchDaemons

The three `.plist` configuration files are pre-created and stored in the `launchd` directory of this repo.
1. `com.example.karabiner-vhidmanager.plist`
2. `com.example.karabiner-vhiddaemon.plist`
3. `com.example.kanata.plist`

Copy them to `/Library/LaunchDaemons/`:
```bash
sudo cp launchd/*.plist /Library/LaunchDaemons/
sudo chown root:wheel /Library/LaunchDaemons/com.example.*.plist
```

> ✏️ **Customize Your Setup**
> - Add the `-debug` flag to the `ProgramArguments` array in the Kanata plist for troubleshooting if needed.

---

## Create Log Directory
```bash
sudo mkdir -p /Library/Logs/Kanata
```

## Load LaunchDaemons

**Load Karabiner Services**
```bash
sudo launchctl bootstrap system /Library/LaunchDaemons/com.example.karabiner-vhidmanager.plist
sudo launchctl enable system/com.example.karabiner-vhidmanager.plist

sudo launchctl bootstrap system /Library/LaunchDaemons/com.example.karabiner-vhiddaemon.plist
sudo launchctl enable system/com.example.karabiner-vhiddaemon.plist
```

**Load Kanata Service**
```bash
sudo launchctl bootstrap system /Library/LaunchDaemons/com.example.kanata.plist
sudo launchctl enable system/com.example.kanata.plist
```

---

## Utilities (Manual Start/Stop)

A helper script is available in the `utilities` folder:
- **Restart Kanata**: Run `./utilities/restart_kanata.sh` to stop and start the kanata service quickly.

**Start services manually (without script):**
```bash
sudo launchctl start com.example.karabiner-vhidmanager
sudo launchctl start com.example.karabiner-vhiddaemon
sudo launchctl start com.example.kanata
```

**Check service status:**
```bash
sudo launchctl list | grep example
```

---

## Troubleshooting

### Common Issues
- **"IOHIDDeviceOpen error: privilege violation"**
  - **Cause:** Running without `sudo` or missing Input Monitoring permissions.
  - **Solution:** Ensure the Kanata binary is added to Input Monitoring and Accessibility. (LaunchDaemons run as root natively, so `sudo` is handled).
- **"Couldn't register any device"**
  - **Cause:** Karabiner daemon not running or Input Monitoring permissions missing.
  - **Solution:** Start the Karabiner daemon first. Add Kanata to **System Settings > Privacy & Security > Input Monitoring** and **Accessibility**.
- **"driver_version_mismatched"**
  - **Cause:** Kanata version incompatible with installed Karabiner driver.
  - **Solution:** Check version compatibility and install matching driver version.
- **Service crashes repeatedly (status -6)**
  - **Cause:** Usually permission issues or incorrect binary path.
  - **Solution:** Verify the binary path in the plist file is correct. Check permissions using `sudo launchctl list | grep example`. View logs to confirm. Ensure Input Monitoring permissions are granted.

## Check Logs

View Kanata logs:
```bash
# Error log
sudo tail -f /Library/Logs/Kanata/kanata.err.log

# Output log
sudo tail -f /Library/Logs/Kanata/kanata.out.log
```

---

## Uninstallation

**Remove LaunchDaemons**
```bash
sudo launchctl bootout system /Library/LaunchDaemons/com.example.kanata.plist
sudo launchctl bootout system /Library/LaunchDaemons/com.example.karabiner-vhiddaemon.plist
sudo launchctl bootout system /Library/LaunchDaemons/com.example.karabiner-vhidmanager.plist

sudo rm /Library/LaunchDaemons/com.example.*.plist
```

**Uninstall Karabiner Driver**
Run the uninstall scripts:
```bash
bash '/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/scripts/uninstall/deactivate_driver.sh'

sudo bash '/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/scripts/uninstall/remove_files.sh'

sudo killall Karabiner-VirtualHIDDevice-Daemon
```

**Remove Kanata**
```bash
# If installed via Homebrew
brew uninstall kanata

# If installed via Cargo
cargo uninstall kanata

# Remove config
rm -rf ~/.config/kanata
```
