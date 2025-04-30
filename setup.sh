#!/bin/bash
set -e  # Exit on errors

# Colors for output
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}🚀 Starting Linux Quick Setup${NC}"

# Detect OS
OS=$(grep -Ei 'debian|ubuntu|arch|fedora' /etc/os-release -m 1 | cut -d= -f2)
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
    sudo apt install -y git curl wget x11-xserver-utils;;
    *Fedora*)
        sudo dnf update -y
    sudo dnf install -y git curl wget xorg-x11-server-utils;;
    *Arch*)
        sudo pacman -Syu --noconfirm
    sudo pacman -S --noconfirm git curl wget xorg-server;;
esac

# Install core tools
echo -e "${GREEN}🔧 Installing essential tools...${NC}"
case "$OS" in
    *Ubuntu*|*Debian*) sudo apt install -y build-essential;;
    *Fedora*) sudo dnf install -y @development-tools;;
    *Arch*) sudo pacman -S --noconfirm base-devel;;
esac

# Install Snapd
echo -e "${GREEN}🔌 Installing Snapd...${NC}"
case "$OS" in
    *Ubuntu*|*Debian*)
        sudo apt install -y snapd
        sudo systemctl enable --now snapd
    sudo ln -s /var/lib/snapd/snap /snap;;
    *Fedora*)
        sudo dnf install -y snapd
        sudo systemctl enable --now snapd.socket
        sudo ln -s /var/lib/snapd/snap /snap
    sudo snap install core;;
    *Arch*)
        if command -v yay &> /dev/null; then
            yay -S --noconfirm snapd
            sudo systemctl enable --now snapd.socket
            sudo ln -s /var/lib/snapd/snap /snap
        else
            echo "⚠️ AUR helper 'yay' not found. Skipping Snapd on Arch."
    fi;;
esac

# Install Brave Browser
echo -e "${GREEN}🌐 Installing Brave Browser...${NC}"
if ! command -v brave-browser &> /dev/null; then
    curl -fsS https://dl.brave.com/install.sh | sh
else
    echo "Brave already installed."
fi

# Debloat Brave using DotRYOT fork
echo -e "${GREEN}🧹 Applying DotRYOT Brave debloat...${NC}"
if [ ! -d "fast-brave-debloater" ]; then
    git clone https://github.com/DotRYOT/fast-brave-debloater.git
fi
cd fast-brave-debloater || { echo "❌ Failed to access debloat dir"; exit 1; }
chmod +x brave_debloat.sh
sudo ./brave_debloat.sh || echo "⚠️ Debloat failed (check script logs)"
cd ..

# Install Visual Studio Code
echo -e "${GREEN}📦 Installing Visual Studio Code...${NC}"
case "$OS" in
    *Ubuntu*|*Debian*)
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor > packages.microsoft.gpg
        sudo install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/
        echo "deb [signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
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
    sudo snap install code --classic || echo "⚠️ Fallback to AUR required";;
esac

# Set resolution to 1920x1080
echo -e "${GREEN}🖥️ Setting resolution to 1920x1080...${NC}"
if xrandr | grep -q connected; then
    MODEL_LINE=$(cvt 1920 1080 | grep Modeline | awk '{print $5 " " $6 " " $7 " " $8 " " $9 " " $10}')
    if ! xrandr | grep -q "1920x1080"; then
        xrandr --newmode "1920x1080" $MODEL_LINE
        xrandr --addmode $(xrandr | grep " connected" | cut -d' ' -f1) "1920x1080"
    fi
    xrandr --output $(xrandr | grep " connected" | cut -d' ' -f1) --mode "1920x1080"
    
    # Persistent resolution
  cat > ~/.screenresolution.sh <<EOF
#!/bin/sh
xrandr --newmode "1920x1080" $MODEL_LINE
xrandr --addmode $(xrandr | grep " connected" | cut -d' ' -f1) "1920x1080"
xrandr --output $(xrandr | grep " connected" | cut -d' ' -f1) --mode "1920x1080"
EOF
    chmod +x ~/.screenresolution.sh
    mkdir -p ~/.config/autostart
  cat > ~/.config/autostart/screenresolution.desktop <<EOF
[Desktop Entry]
Type=Application
Exec=~/.screenresolution.sh
X-GNOME-Autostart-enabled=true
Name=Screen Resolution
Comment=Set resolution to 1920x1080
EOF
fi

# Enable dark mode
echo -e "${GREEN}🌑 Enabling dark mode...${NC}"
gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark" 2>/dev/null || true
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark" 2>/dev/null || true

# KDE dark theme
if command -v kwriteconfig5 &> /dev/null; then
    kwriteconfig5 --file ~/.config/kdeglobals --group "General" --key "ColorScheme" "BreezeDark"
    qdbus org.kde.KWin /KWin reconfigure
fi

# Firefox dark mode
mkdir -p ~/.mozilla/firefox/
echo 'user_pref("browser.theme.dark-mode", true);' >> ~/.mozilla/firefox/prefs.js 2>/dev/null || true

# Git config
read -p "Enter Git name: " GIT_NAME
read -p "Enter Git email: " GIT_EMAIL
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

# Generate SSH Key
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 4096 -N "" -C "$GIT_EMAIL"
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_rsa
    echo -e "${GREEN}📋 Your SSH public key:${NC}"
    cat ~/.ssh/id_rsa.pub
fi

# Dotfiles
ln -sf $(pwd)/.bashrc_custom ~/.bashrc_custom
echo "source ~/.bashrc_custom" >> ~/.bashrc

echo -e "${GREEN}✅ Setup complete! Restart your shell/session.${NC}"