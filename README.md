# Linux Quick Start Script

Automates setup for Ubuntu/Fedora/Arch with:

- Essential CLI tools
- GUI apps (VS Code, GNOME Tweaks)
- Git setup
- Dotfiles

### ⚠️ Snap Considerations

- **Performance**: Snap apps may be slower to start than native packages.
- **Disk Usage**: Snaps bundle dependencies, increasing storage usage.
- **Security**: Sandboxing improves security but may limit access to files/system resources.

### 🧩 Tips

- Want lighter alternatives? Replace Snaps with native packages (e.g., `apt install code` on Ubuntu).
- To manage Snaps:

  ```bash
  snap list          # View installed Snaps
  snap refresh       # Update all Snaps
  snap remove <app>  # Remove a Snap

  ## ⚠️ Brave Browser Installation Notes

  ```

- **Method Used**: Official Brave installer script (`curl -fsS https://dl.brave.com/install.sh | sh`)
- **Why Not Snap?**: Brave prioritizes `.deb/.rpm` packages over Snap for performance and security.
- **Privacy Note**: Brave is privacy-focused, but always review third-party software licenses.

> ⚠️ Note: Snaps may have limited filesystem access. For full integration, consider native packages or flatpak alternatives.

## 🔐 Security Considerations

- The Brave installer script is widely used but still involves trusting external code.
- Always verify the script URL (`https://dl.brave.com/install.sh`) points to Brave's official servers.
- Review Brave's [security documentation](https://github.com/brave/brave-browser/wiki/Installation#linux).

## 💡 Brave Browser Debloat Integration  
- Integrates [`DotRYOT/fast-brave-debloat`](https://github.com/DotRYOT/fast-brave-debloat) to remove bloat like telemetry, sponsored content, and unused features.  
- Fork from [fast-brave-debloater](https://github.com/nomadxxxx/fast-brave-debloater).  

> ⚠️ Warning: Debloat scripts may disable features like ad-blocking or auto-updates. Test functionality post-install.  

## 💡 Applications Installed

### Visual Studio Code
- Installed via Microsoft's official repositories for Debian/Ubuntu/Fedora (performance-focused).
- Falls back to Snap/AUR on Arch-based systems.

### Surfshark VPN
- Installed via Snap (official method) [[4]] or legacy script [[6]].
- After installation:
  1. Launch Surfshark and log in.
  2. Configure protocols (OpenVPN, WireGuard, IKEv2) under Advanced Settings [[2]].
  3. Route specific apps (like VS Code) through the VPN using subnet rules [[3]].

## 💡 Display Configuration

### Resolution to 1920x1080
- Uses `xrandr` and `cvt` to dynamically calculate refresh rates [[6]](https://askubuntu.com/a/1071644).
- Makes resolution persistent across reboots via autostart scripts [[5]](https://forums.linuxmint.com/viewtopic.php?t=274148).

### Dark Mode
- Enables Adwaita Dark theme for GNOME and Breeze Dark for KDE [[8]](https://askubuntu.com/a/1286291).
- Applies dark themes to Firefox and terminal emulators.

> ⚠️ Note: Some hardware/drivers may require manual adjustments in `/etc/X11/xorg.conf.d/`.

## Run:

```bash
curl -fsSL https://raw.githubusercontent.com/DotRYOT/quickstart/refs/heads/main/setup.sh | bash
```
