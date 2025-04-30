# 🐧 Linux Quick Setup Script  
*A fully automated Linux environment configuration tool*  

---

## 🔍 What This Is  
This repository contains a Bash script (`setup.sh`) designed to automate the installation of essential tools, GUI applications, and system settings on Debian/Ubuntu, Fedora, and Arch-based Linux distributions. It streamlines development workflows by configuring Brave Browser, Visual Studio Code, Surfshark VPN, display settings, and dark mode themes in one command .  

---

## ✅ Key Features  
- **Core Tools**: Git, build utilities, and package managers  
- **Browsers**: Brave Browser (with [DotRYOT’s debloat script](https://github.com/DotRYOT/fast-brave-debloater))   
- **Code Editors**: Visual Studio Code (native packages or Snap)  
- **Security & Privacy**: Surfshark VPN integration  
- **Display Settings**: Resolution set to 1920x1080 and persistent across reboots  
- **Dark Mode**: GNOME/KDE themes, Firefox, and terminal support  
- **LAMP Stack**: Apache, MySQL/MariaDB, PHP (CLI + extensions), Composer, Laravel Valet, Redis, OPcache, and phpMyAdmin   
- **Dotfiles**: Custom aliases and shell configurations  

---

## 🚀 How to Use  
### One-Step Install  
Run this command in your terminal (requires `curl` and internet access):  
```bash
curl -fsSL https://raw.githubusercontent.com/DotRYOT/quickstart/refs/heads/main/setup.sh | bash
```

### Manual Setup  
1. Clone the repo:  
   ```bash
   git clone https://github.com/YOUR_USERNAME/linux-quickstart.git
   ```
2. Make the script executable:  
   ```bash
   chmod +x linux-quickstart/setup.sh
   ```
3. Run it:  
   ```bash
   ./linux-quickstart/setup.sh
   ```

---

## ⚠️ Safety Considerations  
- **Review the script** before running it, especially since it uses `sudo` and downloads third-party tools like Brave and Snap apps .  
- Avoid running it on production systems without testing in a VM/container first.  
- Internet connectivity is required for package downloads.  

---

## 📋 Requirements  
- **OS**: Debian, Ubuntu, Fedora, or Arch-based distribution  
- **Permissions**: Sudo access  
- **Tools**: `git`, `curl`, `wget`, and `xrandr` (for resolution settings)  

---

## 🛠️ Customization Options  
- **Resolution**: Edit `1920x1080` in `setup.sh` to match your display .  
- **Theme**: Modify `Adwaita-dark` or `BreezeDark` for alternative dark modes .  
- **Applications**: Add/remove tools (e.g., Slack, Discord) in the Snap app section.  

---

## 🤝 Contributing  
Contributions are welcome! Fork the repo and submit pull requests for:  
- New application integrations  
- OS-specific fixes (e.g., CentOS/RHEL support)  
- Improved error handling  

---

## 📄 License  
MIT License – See [LICENSE](LICENSE) for details.  

---

## 💡 Acknowledgments  
- Inspired by community-driven projects like [SlimBrave](https://github.com/ltx0101/SlimBrave) and [brave-debloatinator](https://github.com/MulesGaming/brave-debloatinator).  
- Uses [DotRYOT’s Brave debloat script](https://github.com/DotRYOT/fast-brave-debloater) for privacy enhancements.  
- Follows best practices from [GitHub's README guides](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-readmes).