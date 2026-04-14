#!/bin/bash

set -e

REPO_URL="https://github.com/altcornix/dotiki.git"
TEMP_DIR="$HOME/.dotfiles-temp"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config.backup-$(date +%s)"

echo "[*] Starting the installer..."

echo "[*] Installing dependencies..."

# базовые пакеты (pacman)
PACKAGES=(
    git
    hyprland
    kitty
    rofi
    starship
    fastfetch
    cava
    waybar
    wl-clipboard
    xdg-desktop-portal-hyprland
    mpv
    firefox
)

sudo pacman -S --needed "${PACKAGES[@]}"

if ! command -v yay &>/dev/null; then
    echo "[*] Installing yay..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
fi

# AUR пакеты (если нужны)
AUR_PACKAGES=(
    quickshell
)

if [ ${#AUR_PACKAGES[@]} -ne 0 ]; then
    echo "[*] Installing AUR packages..."
    yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"
fi

echo "[*] Cloning repo..."
rm -rf "$TEMP_DIR"
git clone "$REPO_URL" "$TEMP_DIR"

DOTFILES_DIR="$TEMP_DIR/config"

if [ ! -d "$DOTFILES_DIR" ]; then
    echo "[!] config folder not found!"
    exit 1
fi

mkdir -p "$CONFIG_DIR"
mkdir -p "$BACKUP_DIR"

echo "[*] Installing dotfiles..."

for item in "$DOTFILES_DIR"/*; do
    [ -e "$item" ] || continue

    name=$(basename "$item")
    target="$CONFIG_DIR/$name"

    echo "[*] $name"

    if [ -e "$target" ] || [ -L "$target" ]; then
        echo "    -> backup"
        mv "$target" "$BACKUP_DIR/"
    fi

    ln -s "$item" "$target"
done

rm -rf "$TEMP_DIR"

echo "[✓] Done!"
echo "[i] Backup: $BACKUP_DIR"
