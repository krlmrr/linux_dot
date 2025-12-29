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

# Refresh keyrings first
info "Refreshing package keyrings..."
sudo pacman -Sy --noconfirm archlinux-keyring cachyos-keyring 2>/dev/null || sudo pacman -Sy --noconfirm archlinux-keyring

# Install packages
info "Installing packages..."
PACKAGES=(
    # Terminal & Shell
    ghostty
    zsh
    tmux

    # Window Manager & Bar
    hyprland
    waybar
    rofi
    swaybg
    mako
    sddm

    # Editor
    neovim

    # PHP Development (PHP itself installed via php.new)
    docker
    docker-compose
    nodejs
    npm

    # Fonts
    ttf-firacode-nerd

    # Key remapping
    keyd

    # File Manager
    nautilus

    # Utilities
    git
    lazygit
    ripgrep
    fd
    brightnessctl
    jq
    solaar
)

sudo pacman -S --needed --noconfirm "${PACKAGES[@]}"

# Remove unwanted packages
info "Removing unwanted packages..."
sudo pacman -Rns --noconfirm alacritty kitty fish cachyos-fish-config fish-autopair fish-pure-prompt fisher 2>/dev/null || true

# Install AUR packages if paru is available
if command -v paru &> /dev/null; then
    info "Installing AUR packages..."
    paru -S --needed --noconfirm ddev-bin 1password logiops sddm-astronaut-theme 2>/dev/null || warn "Some AUR packages skipped"
fi

# Create config directories
info "Creating config directories..."
mkdir -p ~/.config/{hypr,nvim,ghostty,waybar,rofi,mako}

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

# Mako
create_symlink "$DOTFILES_DIR/mako/config" ~/.config/mako/config

# Zsh
create_symlink "$DOTFILES_DIR/zsh/.zshrc" ~/.zshrc

# Tmux
create_symlink "$DOTFILES_DIR/tmux/tmux.conf" ~/.tmux.conf

# Install MonoLisa font
info "Installing MonoLisa font..."
mkdir -p ~/.local/share/fonts
unzip -o "$DOTFILES_DIR/fonts/monolisa-font-main.zip" -d /tmp/monolisa
cp /tmp/monolisa/monolisa-font-main/fonts/*.ttf ~/.local/share/fonts/
fc-cache -f ~/.local/share/fonts/
rm -rf /tmp/monolisa

# Setup keyd
info "Setting up keyd..."
sudo mkdir -p /etc/keyd
sudo rm -f /etc/keyd/default.conf
sudo ln -s "$DOTFILES_DIR/keyd/default.conf" /etc/keyd/default.conf
sudo systemctl enable keyd
sudo systemctl restart keyd
info "Keyd configured (symlinked from dotfiles)"

# Setup SDDM
info "Setting up SDDM..."
sudo mkdir -p /etc/sddm.conf.d
sudo rm -f /etc/sddm.conf.d/theme.conf
sudo ln -sf "$DOTFILES_DIR/sddm/sddm.conf" /etc/sddm.conf.d/theme.conf
# Copy OneDark theme config and wallpaper to astronaut theme (can't symlink - SDDM can't read home dir)
sudo cp "$DOTFILES_DIR/sddm/theme.conf" /usr/share/sddm/themes/sddm-astronaut-theme/Themes/onedark.conf
sudo cp "$DOTFILES_DIR/wallpapers/peakpx.jpg" /usr/share/sddm/themes/sddm-astronaut-theme/Backgrounds/onedark.jpg
sudo chmod 644 /usr/share/sddm/themes/sddm-astronaut-theme/Themes/onedark.conf
sudo chmod 644 /usr/share/sddm/themes/sddm-astronaut-theme/Backgrounds/onedark.jpg
# Update metadata to use OneDark config
sudo sed -i 's|ConfigFile=Themes/.*\.conf|ConfigFile=Themes/onedark.conf|' /usr/share/sddm/themes/sddm-astronaut-theme/metadata.desktop
# Disable other display managers
sudo systemctl disable ly 2>/dev/null || true
sudo systemctl disable gdm 2>/dev/null || true
sudo systemctl disable lightdm 2>/dev/null || true
# Enable SDDM
sudo systemctl enable sddm
info "SDDM configured with Astronaut theme (OneDark)"

# Setup Docker
info "Setting up Docker..."
sudo systemctl enable docker
sudo systemctl start docker
if ! groups | grep -q docker; then
    sudo usermod -aG docker "$USER"
    warn "Added $USER to docker group. Log out and back in for this to take effect."
fi

# Install Claude Code CLI
info "Installing Claude Code CLI..."
npm install -g @anthropic-ai/claude-code

# Install PHP via php.new (includes PHP, Composer, Laravel)
info "Installing PHP via php.new..."
/bin/bash -c "$(curl -fsSL https://php.new/install/linux)"

# Install oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    info "Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install oh-my-zsh plugins (always use home directory)
OMZ_CUSTOM="$HOME/.oh-my-zsh/custom"
mkdir -p "$OMZ_CUSTOM/plugins"
if [ ! -d "$OMZ_CUSTOM/plugins/zsh-autosuggestions" ]; then
    info "Installing zsh-autosuggestions plugin..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$OMZ_CUSTOM/plugins/zsh-autosuggestions"
fi
if [ ! -d "$OMZ_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    info "Installing zsh-syntax-highlighting plugin..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$OMZ_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# Set Zsh as default shell
if [ "$SHELL" != "/usr/bin/zsh" ]; then
    info "Setting Zsh as default shell..."
    chsh -s /usr/bin/zsh
    warn "Shell changed to Zsh. Log out and back in for this to take effect."
fi

# Set dark mode for GNOME/GTK apps
info "Setting dark mode..."
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'

echo ""
echo -e "${GREEN}=== Setup Complete ===${NC}"
echo ""
echo "Next steps:"
echo "  1. Log out and back in (for docker group and zsh)"
echo "  2. Open Neovim and run :Lazy sync to install plugins"
echo "  3. Press Super+Space to test Rofi"
echo ""
