#!/bin/bash

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Dotfiles Setup Script ==="
echo "Dotfiles directory: $DOTFILES_DIR"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if running on Arch-based system
if ! command -v pacman &> /dev/null; then
    error "This script is designed for Arch-based systems (pacman not found)"
    exit 1
fi

# Install packages
info "Installing packages..."
PACKAGES=(
    # Terminal & Shell
    ghostty
    zsh

    # Window Manager & Bar
    hyprland
    waybar
    rofi

    # Editor
    neovim

    # PHP Development
    php
    php-sqlite
    composer
    docker
    docker-compose

    # Fonts
    ttf-firacode-nerd

    # Key remapping
    keyd

    # Utilities
    git
    ripgrep
    fd
)

sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"

# Install DDEV from AUR if paru is available
if command -v paru &> /dev/null; then
    info "Installing AUR packages..."
    paru -S --needed --noconfirm ddev-bin 2>/dev/null || warn "DDEV installation skipped"
fi

# Create config directories
info "Creating config directories..."
mkdir -p ~/.config/{hypr,nvim,ghostty,waybar,rofi}

# Create symlinks
info "Creating symlinks..."

create_symlink() {
    local src="$1"
    local dest="$2"

    if [ -L "$dest" ]; then
        rm "$dest"
    elif [ -e "$dest" ]; then
        warn "Backing up existing $dest to ${dest}.bak"
        mv "$dest" "${dest}.bak"
    fi

    ln -s "$src" "$dest"
    info "Linked $dest -> $src"
}

# Hyprland
create_symlink "$DOTFILES_DIR/hypr/hyprland.conf" ~/.config/hypr/hyprland.conf

# Neovim
create_symlink "$DOTFILES_DIR/nvim/config" ~/.config/nvim

# Ghostty
create_symlink "$DOTFILES_DIR/ghostty/config" ~/.config/ghostty/config

# Waybar
create_symlink "$DOTFILES_DIR/waybar/config.jsonc" ~/.config/waybar/config.jsonc
create_symlink "$DOTFILES_DIR/waybar/style.css" ~/.config/waybar/style.css

# Rofi
create_symlink "$DOTFILES_DIR/rofi/config.rasi" ~/.config/rofi/config.rasi
create_symlink "$DOTFILES_DIR/rofi/onedark.rasi" ~/.config/rofi/onedark.rasi

# Zsh
create_symlink "$DOTFILES_DIR/zsh/.zshrc" ~/.zshrc

# Setup keyd
info "Setting up keyd..."
sudo mkdir -p /etc/keyd
echo -e "[ids]\n*\n\n[main]\ncapslock = overload(control, esc)" | sudo tee /etc/keyd/default.conf > /dev/null
sudo systemctl enable keyd
sudo systemctl restart keyd
info "Keyd configured (Capslock = Ctrl/Esc)"

# Setup Docker
info "Setting up Docker..."
sudo systemctl enable docker
sudo systemctl start docker
if ! groups | grep -q docker; then
    sudo usermod -aG docker "$USER"
    warn "Added $USER to docker group. Log out and back in for this to take effect."
fi

# Set Zsh as default shell
if [ "$SHELL" != "/usr/bin/zsh" ]; then
    info "Setting Zsh as default shell..."
    chsh -s /usr/bin/zsh
    warn "Shell changed to Zsh. Log out and back in for this to take effect."
fi

echo ""
echo -e "${GREEN}=== Setup Complete ===${NC}"
echo ""
echo "Next steps:"
echo "  1. Log out and back in (for docker group and zsh)"
echo "  2. Open Neovim and run :Lazy sync to install plugins"
echo "  3. Press Super+Space to test Rofi"
echo ""
