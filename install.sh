#!/bin/bash

# Dotfiles install script
# This script copies all configs to ~/.config/ and sets up local binaries

set -e

DOTS_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$HOME/.config"
LOCAL_BIN="$HOME/.local/bin"

echo "╔════════════════════════════════════════════════════════╗"
echo "║           Dotfiles Installation Script                 ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "Installing dotfiles from: $DOTS_DIR"
echo "Target config directory:  $CONFIG_DIR"
echo "Target local bin:         $LOCAL_BIN"
echo ""

# Create directories
mkdir -p "$CONFIG_DIR"
mkdir -p "$LOCAL_BIN"

# List of configs to install
CONFIGS=(
    "hypr"
    "kitty"
    "rofi"
    "alacritty"
    "fish"
    "starship"
    "btop"
    "nvim"
    "cava"
    "swaync"
    "ranger"
    "htop"
    "gtk-3.0"
    "gtk-4.0"
    "fuzzel"
    "zathura"
    "matugen"
    "clipse"
    "eww"
    "qt5ct"
    "qt6ct"
    "wal"
    "Wallpapers"
)

# Install each config
for config in "${CONFIGS[@]}"; do
    if [ -d "$DOTS_DIR/$config" ]; then
        echo "  → Installing $config..."
        rm -rf "$CONFIG_DIR/$config"
        cp -r "$DOTS_DIR/$config" "$CONFIG_DIR/"
    fi
done

# Create matugen output directory (for generated colors)
mkdir -p "$CONFIG_DIR/matugen/output"

# Create end-rs required files (notification daemon generates these)
touch "$CONFIG_DIR/eww/end.scss" "$CONFIG_DIR/eww/end.yuck"

# Install standalone files
echo "  → Installing user-dirs.dirs..."
[ -f "$DOTS_DIR/user-dirs.dirs" ] && cp "$DOTS_DIR/user-dirs.dirs" "$CONFIG_DIR/"

echo "  → Installing mimeapps.list..."
[ -f "$DOTS_DIR/mimeapps.list" ] && cp "$DOTS_DIR/mimeapps.list" "$CONFIG_DIR/"

# Install local bin scripts
if [ -d "$DOTS_DIR/local-bin" ]; then
    echo "  → Installing local scripts to ~/.local/bin/..."
    cp -r "$DOTS_DIR/local-bin/"* "$LOCAL_BIN/"
    chmod +x "$LOCAL_BIN/"*
fi

# Create eww symlink (end-rs expects eww at ~/.local/bin/eww)
if command -v eww &> /dev/null && [ ! -f "$LOCAL_BIN/eww" ]; then
    echo "  → Creating eww symlink..."
    ln -sf "$(which eww)" "$LOCAL_BIN/eww"
fi

# Link wal colors to eww (fixes SCSS import issue)
mkdir -p "$HOME/.cache/wal"
touch "$HOME/.cache/wal/colors.scss" # Create dummy file if missing
ln -sf "$HOME/.cache/wal/colors.scss" "$CONFIG_DIR/eww/colors.scss"

# Create XDG user directories
echo ""
echo "Creating XDG user directories..."
mkdir -p "$HOME/desk" "$HOME/down" "$HOME/docs" "$HOME/tmp"
mkdir -p "$HOME/media/pics/screenshots" "$HOME/media/vids" "$HOME/media/audio"

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║        ✓ Dotfiles installed successfully!              ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "Next steps:"
echo "  - Arch:   Run packages with yay -S \$(grep -v '^#' packages.txt | tr '\\n' ' ')"
echo "  - Fedora: Run ./setup-fedora.sh first"
echo "  - Set fish as shell: chsh -s \$(which fish)"
echo "  - Reload Hyprland:   hyprctl reload"
echo "  - Set GTK theme:     nwg-look"
echo ""
