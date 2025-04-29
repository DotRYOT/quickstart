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