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

```bash
# Clone the repo
git clone git@github.com:sudols/dots.git ~/dev/dots
cd ~/dev/dots

# Install packages (Arch/yay)
yay -S $(grep -v '^#' packages.txt | grep -v '^$' | grep -v '═' | tr '\n' ' ')

# Run install script
./install.sh
```

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

## Notes

- Default browser is set to `firefox-nightly` in `hypr/config/defaults.conf`
- GTK theme requires `adw-gtk3` and configuration via `nwg-look`
- Fish shell should be set as default: `chsh -s /usr/bin/fish`

## Screenshots

_Coming soon_
