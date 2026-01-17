# Dotfiles

My Hyprland configuration files for Arch Linux.

## Contents

| Config        | Description                          |
| ------------- | ------------------------------------ |
| `hypr/`       | Hyprland WM, hyprlock, hypridle      |
| `waybar/`     | Status bar with custom modules       |
| `eww/`        | ElKowars Widgets (dashboard, popups) |
| `kitty/`      | Kitty terminal                       |
| `alacritty/`  | Alacritty terminal                   |
| `rofi/`       | Application launcher                 |
| `fuzzel/`     | Alternative launcher                 |
| `fish/`       | Fish shell config                    |
| `starship/`   | Shell prompt                         |
| `nvim/`       | Neovim (LazyVim)                     |
| `ranger/`     | File manager (with devicons)         |
| `btop/`       | System monitor                       |
| `htop/`       | Process viewer                       |
| `cava/`       | Audio visualizer                     |
| `swaync/`     | Notification center                  |
| `clipse/`     | Clipboard manager                    |
| `zathura/`    | PDF viewer                           |
| `matugen/`    | Material You color generator         |
| `gtk-3.0/`    | GTK3 settings                        |
| `gtk-4.0/`    | GTK4 settings                        |
| `Wallpapers/` | Gruvbox wallpapers                   |
| `local-bin/`  | Custom scripts for ~/.local/bin      |

## Quick Install

### Arch Linux

```bash
# Clone the repo
git clone git@github.com:sudols/dots.git ~/dev/dots
cd ~/dev/dots

# Install packages (Arch/yay)
yay -S $(grep -v '^#' packages.txt | grep -v '^$' | grep -v '═' | tr '\n' ' ')

# Run install script
./install.sh
```

### Fedora

```bash
# Clone the repo
git clone git@github.com:sudols/dots.git ~/dev/dots
cd ~/dev/dots

# Run Fedora setup (enables COPRs, installs packages, builds from source)
./setup-fedora.sh

# Copy dotfiles to ~/.config
./install.sh
```

> **Note:** `setup-fedora.sh` will build packages like eww, matugen, and clipse from source since they're not in Fedora repos.

## What the Install Script Does

1. Copies all config folders to `~/.config/`
2. Copies custom scripts to `~/.local/bin/`
3. Creates XDG user directories

## XDG User Directories

This setup uses custom XDG directories:
| Standard | Custom |
|----------|--------|
| Desktop | `~/desk` |
| Downloads | `~/down` |
| Documents | `~/docs` |
| Templates | `~/tmp` |
| Pictures | `~/media/pics/` |
| Videos | `~/media/vids/` |
| Music | `~/media/audio/` |
| Screenshots | `~/media/pics/screenshots/` |

## Key Bindings (Hyprland)

| Keybind          | Action              |
| ---------------- | ------------------- |
| `Super + Return` | Terminal (Kitty)    |
| `Super + M`      | App Launcher (Rofi) |
| `Super + W`      | Browser             |
| `Super + V`      | Clipboard Manager   |
| `Super + C`      | Color Picker        |
| `Print`          | Screenshot (area)   |
| `Super + 1-6`    | Switch workspace    |

## Dependencies

See `packages.txt` for the full list. Key components:

**Core**: hyprland, hyprlock, hypridle, waybar, eww, swaync
**Utils**: swww (wallpaper), grimblast (screenshot), hyprpicker (color picker), swayosd (OSD)
**Apps**: kitty, rofi, ranger, btop, neovim, zathura

## Theming Guide

### 1. Unified Theming (Matugen)

Generates colors for Hyprland, Kitty, Rofi, Zephyr, etc. and sets wallpaper:

```bash
matugen image ~/.config/Wallpapers/gruvbox_01.png
```

### 2. Pywal

Alternative color generation:

```bash
wal -i ~/.config/Wallpapers/gruvbox_01.png
```

### 3. GTK & Icons

Configure via GUI:

```bash
nwg-look
```

_Select `adw-gtk3-dark` for theme, `Papirus-Dark` for icons, `Adwaita` for cursor._

### 4. Reloading

Changes usually apply instantly, but if not:

```bash
hyprctl reload
eww reload
```

## Screenshots

_Coming soon_
