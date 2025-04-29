#!/bin/bash

# Exit on errors
set -e

# Colors for output
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}🚀 Starting Linux Quick Setup${NC}"

# Detect OS
OS=$(grep -Ei 'debian|ubuntu|arch|fedora|centos' /etc/os-release -m 1 | cut -d= -f2)

if [[ -z "$OS" ]]; then
    echo "Unsupported OS"
    exit 1
fi

echo "Detected OS: $OS"

# Ask for sudo upfront
sudo -v

# Update system
case "$OS" in
    *Ubuntu*|*Debian*)
        sudo apt update && sudo apt upgrade -y
    sudo apt install -y git curl wget vim;;
    *Fedora*)
        sudo dnf update -y
    sudo dnf install -y git curl wget vim;;
    *Arch*)
        sudo pacman -Syu --noconfirm
    sudo pacman -S --noconfirm git curl wget vim;;
esac

# Install base tools
echo -e "${GREEN}🔧 Installing essential tools...${NC}"
case "$OS" in
    *Ubuntu*|*Debian*) sudo apt install -y build-essential;;
    *Fedora*) sudo dnf install -y @development-tools;;
    *Arch*) sudo pacman -S --noconfirm base-devel;;
esac

# Install GUI apps (example)
echo -e "${GREEN}🧩 Installing GUI applications...${NC}"
case "$OS" in
    *Ubuntu*|*Debian*)
    sudo apt install -y code gnome-tweaks;;
    *Fedora*)
    sudo dnf install -y code gnome-tweak-tool;;
    *Arch*)
    yay -S --noconfirm visual-studio-code-bin gnome-tweaks;;
esac

# Install Snapd (if available) and GUI apps via Snap
echo -e "${GREEN}🔌 Installing Snapd and GUI apps...${NC}"

case "$OS" in
    *Ubuntu*|*Debian*)
        # Install & enable Snapd
        sudo apt install -y snapd
        sudo systemctl enable --now snapd
        sudo ln -s /var/lib/snapd/snap /snap
        
        # Install Snap apps
        sudo snap install code --classic     # Visual Studio Code
        sudo snap install slack              # Slack
        sudo snap install discord            # Discord
    ;;
    
    *Fedora*)
        # Install Snapd
        sudo dnf install -y snapd
        sudo systemctl enable --now snapd.socket
        sudo ln -s /var/lib/snapd/snap /snap
        
        # Install Core Snap (required)
        sudo snap install core
        
        # Install Snap apps
        sudo snap install code --classic
        sudo snap install slack
        sudo snap install discord
    ;;
    
    *Arch*)
        # Install Snapd via AUR (requires yay/paru)
        if command -v yay &> /dev/null; then
            yay -S --noconfirm snapd
            sudo systemctl enable --now snapd.socket
            sudo ln -s /var/lib/snapd/snap /snap
            
            # Install Snap apps
            sudo snap install code --classic
            sudo snap install slack
            sudo snap install discord
        else
            echo "⚠️  AUR helper 'yay' not found. Skipping Snapd on Arch."
        fi
    ;;
esac

echo -e "${GREEN}💡 Note: Restart your session to use Snap apps fully.${NC}"

# Install Brave Browser (official repo)
echo -e "${GREEN}🌐 Installing Brave Browser...${NC}"

# Check for existing Brave installation
if command -v brave-browser &> /dev/null; then
    echo "Brave Browser is already installed."
else
    # Run Brave's official install script
    curl -fsS https://dl.brave.com/install.sh | sh
fi

# Optional: Verify installation
if command -v brave-browser &> /dev/null; then
    echo -e "${GREEN}✅ Brave Browser successfully installed.${NC}"
else
    echo -e "${RED}❌ Failed to install Brave Browser. Check Brave's documentation for manual steps.${NC}"
fi

read -p "Apply Brave Browser debloat using DotRYOT's script? [y/N] " APPLY_DEBLOAT
if [[ "$APPLY_DEBLOAT" =~ ^[Yy]$ ]]; then
    # Insert the debloat commands here
fi

# Apply DotRYOT's Brave debloat script
echo -e "${GREEN}🧹 Applying Brave Browser debloat using DotRYOT/fast-brave-debloater...${NC}"

# Clone the repository (skip if already exists)
if [ ! -d "fast-brave-debloat" ]; then
    git clone https://github.com/DotRYOT/fast-brave-debloat.git
fi

# Navigate to the script directory
cd fast-brave-debloat || { echo "❌ Failed to access fast-brave-debloat directory"; exit 1; }

# Ensure the script is executable
chmod +x brave_debloat.sh

# Run the debloat script with sudo
if sudo ./brave_debloat.sh; then
    echo -e "${GREEN}✅ Brave Browser debloated successfully.${NC}"
else
    echo -e "${RED}❌ Failed to debloat Brave Browser. Check script logs for errors.${NC}"
fi

cd ..

# Install Visual Studio Code (native packages first, fallback to Snap)
echo -e "${GREEN}📦 Installing Visual Studio Code...${NC}"

case "$OS" in
    *Ubuntu*|*Debian*)
        # Official .deb repo setup
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor > packages.microsoft.gpg
        sudo install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
    sudo apt update && sudo apt install -y code;;
    *Fedora*)
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
        echo "[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
        gpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
    sudo dnf install -y code;;
    *Arch*)
        # Fallback to Snap if native package isn't preferred
    yay -S --noconfirm visual-studio-code-bin || sudo snap install code --classic;;
esac

echo -e "${GREEN}✅ Visual Studio Code installed.${NC}"

read -p "Configure Surfshark to route only VS Code through the VPN? [y/N] " ROUTE_VSCODE
if [[ "$ROUTE_VSCODE" =~ ^[Yy]$ ]]; then
    echo "Manual step: Edit OpenVPN config to route only VS Code traffic [[3]]."
fi

# Install Surfshark VPN
echo -e "${GREEN}🔒 Installing Surfshark VPN...${NC}"

if command -v surfshark &> /dev/null; then
    echo "Surfshark is already installed."
else
    case "$OS" in
        *Ubuntu*|*Debian*|*Fedora*)
            # Install via Snap (official method) [[4]]
        sudo snap install surfshark-vpn;;
        *Arch*)
            # Install via AUR helper or fallback to Snap
            if command -v yay &> /dev/null; then
                yay -S --noconfirm surfshark-vpn
            else
            sudo snap install surfshark-vpn;;
        fi
    esac
fi

# Legacy script fallback (for unsupported distros) [[6]]
if ! command -v surfshark &> /dev/null; then
    echo "⚠️  Falling back to Surfshark legacy installer..."
    curl -O https://downloads.surfshark.com/linux/ubuntu/install-surfshark.sh
    chmod +x install-surfshark.sh
    sudo ./install-surfshark.sh
fi

echo -e "${GREEN}💡 Configure Surfshark in Settings > Network > VPN after login.${NC}"

read -p "Set resolution to 1920x1080? [y/N] " APPLY_RES
if [[ "$APPLY_RES" =~ ^[Yy]$ ]]; then
    # Set resolution to 1920x1080 (persistent across reboots)
    echo -e "${GREEN}🖥️ Configuring display resolution to 1920x1080...${NC}"
    
    # Generate custom resolution modeline
    MODEL_LINE=$(cvt 1920 1080 | grep Modeline | awk '{print $5 " " $6 " " $7 " " $8 " " $9 " " $10}')
    
    # Check if the resolution already exists
    if ! xrandr | grep -q "1920x1080"; then
        # Add new resolution
        xrandr --newmode "1920x1080" $MODEL_LINE
        xrandr --addmode $(xrandr | grep " connected" | cut -d' ' -f1) "1920x1080"
    fi
    
    # Apply resolution
    xrandr --output $(xrandr | grep " connected" | cut -d' ' -f1) --mode "1920x1080"
    
    # Make resolution persistent (add to startup)
    echo "#!/bin/sh
xrandr --newmode \"1920x1080\" $MODEL_LINE
xrandr --addmode $(xrandr | grep " connected" | cut -d' ' -f1) \"1920x1080\"
xrandr --output $(xrandr | grep " connected" | cut -d' ' -f1) --mode \"1920x1080\"" > ~/.screenresolution.sh

chmod +x ~/.screenresolution.sh

# Add to autostart (GNOME/Ubuntu)
mkdir -p ~/.config/autostart
    echo "[Desktop Entry]
    Type=Application
    Exec=~/.screenresolution.sh
    Hidden=false
    NoDisplay=false
    X-GNOME-Autostart-enabled=true
    Name=Screen Resolution
    Comment=Set resolution to 1920x1080" > ~/.config/autostart/screenresolution.desktop
    
    echo -e "${GREEN}✅ Resolution set to 1920x1080 and made persistent.${NC}"
fi

read -p "Enable dark mode? [y/N] " APPLY_DARK
if [[ "$APPLY_DARK" =~ ^[Yy]$ ]]; then
    # Enable dark mode for GNOME/KDE/Firefox
    echo -e "${GREEN}🌑 Enabling dark mode globally...${NC}"
    
    # GNOME (Adwaita Dark Theme)
    gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
    gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
    
    # KDE (System Settings)
    if command -v kwriteconfig5 &> /dev/null; then
        kwriteconfig5 --file ~/.config/kdeglobals --group "General" --key "ColorScheme" "BreezeDark"
        kwriteconfig5 --file ~/.config/kwinrc --group "Windows" --key "BorderSize" "None"
        qdbus org.kde.KWin /KWin reconfigure
    fi
    
    # Firefox (via preferences file)
    mkdir -p ~/.mozilla/firefox/
    firefox_prefs="$HOME/.mozilla/firefox/prefs.js"
    if [ -f "$firefox_prefs" ]; then
        echo "user_pref(\"browser.theme.dark-mode\", true);" >> "$firefox_prefs"
    fi
    
    # Terminal Emulator (e.g., gnome-terminal)
    if command -v gsettings &> /dev/null; then
        gsettings set org.gnome.Terminal.ProfilesList default '/org/gnome/Terminal/Profiles/org.gnome.Terminal.Profile.Linux'
    fi
    
    echo -e "${GREEN}✅ Dark mode enabled for GNOME/KDE, Firefox, and terminal.${NC}"
fi

# Configure Git
read -p "Enter Git name: " GIT_NAME
read -p "Enter Git email: " GIT_EMAIL
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

# Generate SSH Key (if missing)
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 4096 -N "" -C "$GIT_EMAIL"
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_rsa
    echo -e "${GREEN}📋 Your SSH public key:${NC}"
    cat ~/.ssh/id_rsa.pub
fi

# Symlink dotfiles
echo -e "${GREEN}📂 Setting up dotfiles...${NC}"
ln -sf $(pwd)/.bashrc_custom ~/.bashrc_custom
echo "source ~/.bashrc_custom" >> ~/.bashrc

# Final message
echo -e "${GREEN}✅ Setup complete! Restart your shell.${NC}"