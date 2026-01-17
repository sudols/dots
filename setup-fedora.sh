#!/bin/bash

# Fedora Hyprland Setup Script
# Run this BEFORE install.sh to set up Fedora-specific dependencies

set -e

echo "╔════════════════════════════════════════════════════════╗"
echo "║        Fedora Hyprland Setup Script                    ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Check if running on Fedora
if ! grep -q "Fedora" /etc/os-release 2>/dev/null; then
    echo "⚠️  Warning: This script is designed for Fedora. You appear to be running a different distro."
    read -p "Continue anyway? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

DOTS_DIR="$(cd "$(dirname "$0")" && pwd)"

# ═══════════════════════════════════════════════════════════════
# STEP 1: Update system first (prevents Qt version conflicts)
# ═══════════════════════════════════════════════════════════════
echo ""
echo "📦 Updating system packages first..."
echo ""

sudo dnf upgrade -y --refresh

echo "✓ System updated"

# ═══════════════════════════════════════════════════════════════
# STEP 2: Enable COPRs (some may not be available for your Fedora version)
# ═══════════════════════════════════════════════════════════════
echo ""
echo "📦 Enabling available COPR repositories..."
echo ""

# Hyprland ecosystem (required)
sudo dnf copr enable -y solopasha/hyprland || echo "⚠️  Hyprland COPR not available, will need manual install"

# SwayNotificationCenter (optional - will build from source if unavailable)
sudo dnf copr enable -y erikreider/SwayNotificationCenter 2>/dev/null || echo "ℹ️  SwayNotificationCenter COPR not available for this Fedora version"

# SwayOSD - often unavailable for newer Fedora, will build from source
sudo dnf copr enable -y erikreider/SwayOSD 2>/dev/null || echo "ℹ️  SwayOSD COPR not available, will build from source"

echo ""
echo "✓ COPR setup complete"

# ═══════════════════════════════════════════════════════════════
# STEP 2: Install essential build tools first
# ═══════════════════════════════════════════════════════════════
echo ""
echo "🔧 Installing essential build tools (needed for later steps)..."
echo ""

# These are needed for building from source - install explicitly first
sudo dnf install -y --skip-unavailable \
    gcc gcc-c++ make cmake meson ninja-build \
    cargo rust golang python3-pip git curl unzip \
    gtk4-devel gtk-layer-shell-devel libadwaita-devel \
    json-glib-devel pulseaudio-libs-devel libevdev-devel \
    libinput-devel sassc glib2-devel libdbusmenu-gtk3-devel \
    vala scdoc

echo "✓ Build tools ready"

# ═══════════════════════════════════════════════════════════════
# STEP 3: Install packages from package list
# ═══════════════════════════════════════════════════════════════
echo ""
echo "📦 Installing packages from packages-fedora.txt..."
echo ""

if [ -f "$DOTS_DIR/packages-fedora.txt" ]; then
    # Filter comments and empty lines, install all at once
    # Use --skip-unavailable to handle missing/conflicting packages
    PACKAGES=$(grep -v '^#' "$DOTS_DIR/packages-fedora.txt" | grep -v '^$' | tr '\n' ' ')
    sudo dnf install -y --skip-unavailable $PACKAGES || echo "⚠️  Some packages may have failed, continuing..."
else
    echo "⚠️  packages-fedora.txt not found, skipping package installation"
fi

# ═══════════════════════════════════════════════════════════════
# STEP 3: Install COPR packages (if available)
# ═══════════════════════════════════════════════════════════════
echo ""
echo "📦 Attempting to install COPR packages..."
echo ""

# Try to install from COPR, failures are OK - we'll build from source
sudo dnf install -y SwayNotificationCenter 2>/dev/null || echo "ℹ️  SwayNotificationCenter not in repos, will build from source"
sudo dnf install -y swayosd 2>/dev/null || echo "ℹ️  SwayOSD not in repos, will build from source"

# ═══════════════════════════════════════════════════════════════
# STEP 4: Install Nerd Fonts
# ═══════════════════════════════════════════════════════════════
echo ""
echo "🔤 Installing Nerd Fonts..."
echo ""

FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

# Download and install JetBrains Mono Nerd Font
if [ ! -f "$FONT_DIR/JetBrainsMonoNerdFont-Regular.ttf" ]; then
    echo "  → Downloading JetBrains Mono Nerd Font..."
    curl -fLo "/tmp/JetBrainsMono.zip" \
        "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
    unzip -o "/tmp/JetBrainsMono.zip" -d "$FONT_DIR"
    rm "/tmp/JetBrainsMono.zip"
fi

# Download and install FiraCode Nerd Font
if [ ! -f "$FONT_DIR/FiraCodeNerdFont-Regular.ttf" ]; then
    echo "  → Downloading FiraCode Nerd Font..."
    curl -fLo "/tmp/FiraCode.zip" \
        "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip"
    unzip -o "/tmp/FiraCode.zip" -d "$FONT_DIR"
    rm "/tmp/FiraCode.zip"
fi

# Refresh font cache
fc-cache -fv

echo "✓ Nerd Fonts installed"

# ═══════════════════════════════════════════════════════════════
# STEP 6: Install packages not in Fedora repos (pip/cargo)
# ═══════════════════════════════════════════════════════════════
echo ""
echo "📦 Installing pip/cargo packages..."
echo ""

# Starship prompt
if ! command -v starship &> /dev/null; then
    echo "  → Installing starship..."
    cargo install starship --locked || echo "⚠️  starship failed, try: curl -sS https://starship.rs/install.sh | sh"
    echo "  ✓ starship installed"
fi

# Pywal
if ! command -v wal &> /dev/null; then
    echo "  → Installing pywal..."
    pip install --user pywal || python3 -m pip install --user pywal
    echo "  ✓ pywal installed"
fi

# ═══════════════════════════════════════════════════════════════
# STEP 6: Build/Install packages not in repos
# ═══════════════════════════════════════════════════════════════
echo ""
echo "🔧 Building packages from source..."
echo ""

BUILD_DIR="$HOME/.local/src"
mkdir -p "$BUILD_DIR"

# --- Matugen (Material You color generator) ---
if ! command -v matugen &> /dev/null; then
    echo "  → Building matugen..."
    cd "$BUILD_DIR"
    if [ ! -d "matugen" ]; then
        git clone https://github.com/InioX/matugen.git
    fi
    cd matugen
    git pull
    cargo build --release
    cp target/release/matugen "$HOME/.local/bin/"
    echo "  ✓ matugen installed"
fi

# --- Clipse (clipboard manager) ---
if ! command -v clipse &> /dev/null; then
    echo "  → Building clipse..."
    cd "$BUILD_DIR"
    if [ ! -d "clipse" ]; then
        git clone https://github.com/savedra1/clipse.git
    fi
    cd clipse
    git pull
    go build -o clipse .
    cp clipse "$HOME/.local/bin/"
    echo "  ✓ clipse installed"
fi

# --- Grimblast (screenshot helper) ---
if ! command -v grimblast &> /dev/null; then
    echo "  → Installing grimblast..."
    cd "$BUILD_DIR"
    if [ ! -d "contrib" ]; then
        git clone https://github.com/hyprwm/contrib.git
    fi
    cd contrib/grimblast
    sudo make install
    echo "  ✓ grimblast installed"
fi

# --- EWW (widgets) ---
if ! command -v eww &> /dev/null; then
    echo "  → Building eww (this may take a while)..."
    cd "$BUILD_DIR"
    if [ ! -d "eww" ]; then
        git clone https://github.com/elkowar/eww.git
    fi
    cd eww
    git pull
    cargo build --release --no-default-features --features wayland
    cp target/release/eww "$HOME/.local/bin/"
    echo "  ✓ eww installed"
fi

# --- SwayOSD (OSD for volume/brightness) ---
if ! command -v swayosd-server &> /dev/null; then
    echo "  → Building SwayOSD..."
    cd "$BUILD_DIR"
    if [ ! -d "SwayOSD" ]; then
        git clone https://github.com/ErikReider/SwayOSD.git
    fi
    cd SwayOSD
    git pull
    # SwayOSD uses meson
    meson setup build
    ninja -C build
    sudo ninja -C build install
    echo "  ✓ SwayOSD installed"
fi

# --- SwayNotificationCenter (swaync) ---
if ! command -v swaync &> /dev/null; then
    echo "  → Building SwayNotificationCenter..."
    cd "$BUILD_DIR"
    if [ ! -d "SwayNotificationCenter" ]; then
        git clone https://github.com/ErikReider/SwayNotificationCenter.git
    fi
    cd SwayNotificationCenter
    git pull
    meson setup build
    ninja -C build
    sudo ninja -C build install
    echo "  ✓ SwayNotificationCenter installed"
fi

# ═══════════════════════════════════════════════════════════════
# STEP 7: Enable required services
# ═══════════════════════════════════════════════════════════════
echo ""
echo "🔧 Enabling system services..."
echo ""

# Bluetooth
sudo systemctl enable --now bluetooth || true

# PipeWire (usually enabled by default on Fedora)
systemctl --user enable --now pipewire pipewire-pulse wireplumber || true

echo "✓ Services enabled"

# ═══════════════════════════════════════════════════════════════
# STEP 8: Set fish as default shell
# ═══════════════════════════════════════════════════════════════
echo ""
echo "🐟 Setting fish as default shell..."
echo ""

if command -v fish &> /dev/null; then
    FISH_PATH=$(which fish)
    if ! grep -q "$FISH_PATH" /etc/shells; then
        echo "$FISH_PATH" | sudo tee -a /etc/shells
    fi
    
    if [ "$SHELL" != "$FISH_PATH" ]; then
        chsh -s "$FISH_PATH"
        echo "✓ Default shell changed to fish (will take effect on next login)"
    else
        echo "✓ Fish is already your default shell"
    fi
fi

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║   ✓ Fedora setup complete!                             ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "Next steps:"
echo "  1. Run ./install.sh to copy dotfiles"
echo "  2. Log out and select Hyprland from display manager"
echo "  3. Or start with: Hyprland"
echo ""
echo "Note: $HOME/.local/bin should be in your PATH"
echo "      Add to fish config: fish_add_path ~/.local/bin"
echo ""
