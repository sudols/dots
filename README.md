# Dotfiles

My Hyprland configuration files for Arch Linux.

## Contents

| Config        | Description                     |
| ------------- | ------------------------------- |
| `hypr/`       | Hyprland WM, hyprlock, hypridle |
| `waybar/`     | Status bar                      |
| `kitty/`      | Kitty terminal                  |
| `alacritty/`  | Alacritty terminal              |
| `rofi/`       | Application launcher            |
| `fuzzel/`     | Alternative launcher            |
| `fish/`       | Fish shell config               |
| `starship/`   | Shell prompt                    |
| `nvim/`       | Neovim (LazyVim)                |
| `ranger/`     | File manager                    |
| `btop/`       | System monitor                  |
| `htop/`       | Process viewer                  |
| `cava/`       | Audio visualizer                |
| `swaync/`     | Notification center             |
| `clipse/`     | Clipboard manager               |
| `zathura/`    | PDF viewer                      |
| `matugen/`    | Material You color generator    |
| `gtk-3.0/`    | GTK3 settings                   |
| `gtk-4.0/`    | GTK4 settings                   |
| `Wallpapers/` | Gruvbox wallpapers              |

## Quick Install

```bash
# Clone the repo
git clone git@github.com:sudols/dots.git ~/dev/dots
cd ~/dev/dots

# Install packages (Arch/yay)
yay -S $(grep -v '^#' packages.txt | tr '\n' ' ')

# Install configs
./install.sh
```

## Manual Install

```bash
# Copy individual configs
cp -r ~/dev/dots/hypr ~/.config/
cp -r ~/dev/dots/waybar ~/.config/
# ... etc

# Reload Hyprland
hyprctl reload
```

## XDG User Directories

This setup uses custom XDG directories:

- `~/desk` - Desktop
- `~/down` - Downloads
- `~/docs` - Documents
- `~/tmp` - Templates
- `~/media/pics/` - Pictures
- `~/media/vids/` - Videos
- `~/media/audio/` - Music

Create them before installing:

```bash
mkdir -p ~/desk ~/down ~/docs ~/tmp ~/media/{pics,vids,audio}
mkdir -p ~/media/pics/screenshots
```

## Dependencies

See `packages.txt` for the full list of required packages.
