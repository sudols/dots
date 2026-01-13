#!/bin/bash

# Dotfiles install script
# This script copies all configs to ~/.config/

set -e

DOTS_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$HOME/.config"

echo "Installing dotfiles from: $DOTS_DIR"
echo "Target config directory: $CONFIG_DIR"
echo ""

# Create config directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

# List of configs to install
CONFIGS=(
    "hypr"
    "waybar"
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
    "Wallpapers"
)

# Install each config
for config in "${CONFIGS[@]}"; do
    if [ -d "$DOTS_DIR/$config" ]; then
        echo "Installing $config..."
        cp -r "$DOTS_DIR/$config" "$CONFIG_DIR/"
    fi
done

# Install standalone files
[ -f "$DOTS_DIR/user-dirs.dirs" ] && cp "$DOTS_DIR/user-dirs.dirs" "$CONFIG_DIR/"
[ -f "$DOTS_DIR/mimeapps.list" ] && cp "$DOTS_DIR/mimeapps.list" "$CONFIG_DIR/"

echo ""
echo "✓ Dotfiles installed successfully!"
echo ""
echo "Next steps:"
echo "  1. Log out and back in, or run: hyprctl reload"
echo "  2. Install required packages (see packages.txt)"
echo ""
