#!/bin/bash

# Fedora Hyprland Config Setup Script
# For systems with Hyprland already installed (e.g., via JaKooLit installer)
# This installs config-specific packages via dnf/COPR (minimal source builds)

set -e

echo "╔════════════════════════════════════════════════════════╗"
echo "║     Fedora Config Dependencies Setup                   ║"
echo "║     (Hyprland already installed)                       ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Check if running on Fedora
if ! grep -q "Fedora" /etc/os-release 2>/dev/null; then
    echo "⚠️  Warning: This script is designed for Fedora."
    read -p "Continue anyway? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

DOTS_DIR="$(cd "$(dirname "$0")" && pwd)"

# ═══════════════════════════════════════════════════════════════
# STEP 1: Enable COPR repositories
# ═══════════════════════════════════════════════════════════════
echo ""
echo "📦 Enabling COPR repositories..."
echo ""

# EWW widgets
sudo dnf copr enable -y varlad/eww || echo "⚠️  varlad/eww COPR failed"

# Matugen (Material You color generator)
sudo dnf copr enable -y heus-sueh/packages || echo "⚠️  heus-sueh/packages COPR failed"

# Starship prompt
sudo dnf copr enable -y atim/starship || echo "⚠️  atim/starship COPR failed"

# SwayNotificationCenter
sudo dnf copr enable -y erikreider/SwayNotificationCenter 2>/dev/null || echo "ℹ️  SwayNotificationCenter COPR not available"

# SwayOSD
sudo dnf copr enable -y erikreider/SwayOSD 2>/dev/null || echo "ℹ️  SwayOSD COPR not available"

# Clipse clipboard manager
sudo dnf copr enable -y azandure/clipse || echo "⚠️  azandure/clipse COPR failed"

echo "✓ COPR repositories enabled"

# ═══════════════════════════════════════════════════════════════
# STEP 2: Install config-specific packages from dnf
# ═══════════════════════════════════════════════════════════════
echo ""
echo "📦 Installing config-specific packages..."
echo ""

# Core config dependencies (most should be available)
sudo dnf install -y --skip-unavailable \
    eww \
    matugen \
    starship \
    SwayNotificationCenter \
    swayosd \
    alacritty \
    kitty \
    fish \
    rofi-wayland \
    fuzzel \
    btop \
    htop \
    ranger \
    neovim \
    cava \
    wl-clipboard \
    clipse \
    zathura \
    zathura-pdf-mupdf \
    swww \
    grim \
    slurp \
    hyprpicker \
    brightnessctl \
    playerctl \
    pamixer \
    socat \
    libnotify \
    lsd \
    nwg-look \
    qt5ct \
    adw-gtk3-theme \
    papirus-icon-theme \
    nemo \
    loupe

echo "✓ DNF packages installed"

# ═══════════════════════════════════════════════════════════════
# STEP 3: Install Nerd Fonts (needed for eww/starship icons)
# ═══════════════════════════════════════════════════════════════
echo ""
echo "🔤 Installing Nerd Fonts..."
echo ""

FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

if [ ! -f "$FONT_DIR/JetBrainsMonoNerdFont-Regular.ttf" ]; then
    echo "  → Downloading JetBrains Mono Nerd Font..."
    curl -fLo "/tmp/JetBrainsMono.zip" \
        "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
    unzip -o "/tmp/JetBrainsMono.zip" -d "$FONT_DIR"
    rm "/tmp/JetBrainsMono.zip"
fi

if [ ! -f "$FONT_DIR/FiraCodeNerdFont-Regular.ttf" ]; then
    echo "  → Downloading FiraCode Nerd Font..."
    curl -fLo "/tmp/FiraCode.zip" \
        "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip"
    unzip -o "/tmp/FiraCode.zip" -d "$FONT_DIR"
    rm "/tmp/FiraCode.zip"
fi

fc-cache -fv > /dev/null 2>&1
echo "✓ Nerd Fonts installed"

# ═══════════════════════════════════════════════════════════════
# STEP 4: Install pip packages (pywal not in Fedora repos)
# ═══════════════════════════════════════════════════════════════
echo ""
echo "🐍 Installing pip packages..."
echo ""

# Ensure pip is available
sudo dnf install -y python3-pip

if ! command -v wal &> /dev/null; then
    echo "  → Installing pywal..."
    pip install --user pywal
    echo "  ✓ pywal installed"
else
    echo "  ✓ pywal already installed"
fi

mkdir -p "$HOME/.local/bin"

# ═══════════════════════════════════════════════════════════════
# STEP 6: Install grimblast (screenshot helper, simple copy)
# ═══════════════════════════════════════════════════════════════
echo ""
echo "📸 Installing grimblast..."
echo ""

if ! command -v grimblast &> /dev/null; then
    echo "  → Downloading grimblast..."
    curl -fLo "$HOME/.local/bin/grimblast" \
        "https://raw.githubusercontent.com/hyprwm/contrib/main/grimblast/grimblast"
    chmod +x "$HOME/.local/bin/grimblast"
    echo "  ✓ grimblast installed"
else
    echo "  ✓ grimblast already installed"
fi

# ═══════════════════════════════════════════════════════════════
# STEP 7: Set fish as default shell
# ═══════════════════════════════════════════════════════════════
echo ""
echo "🐟 Configuring fish shell..."
echo ""

if command -v fish &> /dev/null; then
    FISH_PATH=$(which fish)
    if ! grep -q "$FISH_PATH" /etc/shells; then
        echo "$FISH_PATH" | sudo tee -a /etc/shells
    fi
    
    if [ "$SHELL" != "$FISH_PATH" ]; then
        echo "  → To set fish as default shell, run:"
        echo "    chsh -s $FISH_PATH"
    else
        echo "  ✓ Fish is already your default shell"
    fi
fi

# ═══════════════════════════════════════════════════════════════
# STEP 8: Ensure ~/.local/bin is in PATH
# ═══════════════════════════════════════════════════════════════
echo ""
echo "🔧 Checking PATH configuration..."
echo ""

if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo "  ⚠️  ~/.local/bin is not in PATH"
    echo "  → Add to fish config: fish_add_path ~/.local/bin"
    echo "  → Or add to ~/.bashrc: export PATH=\"\$HOME/.local/bin:\$PATH\""
else
    echo "  ✓ ~/.local/bin is in PATH"
fi

# ═══════════════════════════════════════════════════════════════
# SUMMARY
# ═══════════════════════════════════════════════════════════════
echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║   ✓ Setup complete!                                    ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "Installed via COPR/DNF:"
echo "  • eww, matugen, starship, swaync, swayosd"
echo "  • alacritty, kitty, fish, cava, ranger, etc."
echo ""
echo "Installed via pip:"
echo "  • pywal"
echo ""
echo "Installed via go:"
echo "  • clipse"
echo ""
echo "Next steps:"
echo "  1. Run ./install.sh to copy dotfiles"
echo "  2. Set fish as shell: chsh -s $(which fish)"
echo "  3. Log out and log back in"
echo "  4. Set GTK theme with: nwg-look"
echo ""
