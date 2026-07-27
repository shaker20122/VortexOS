#!/bin/bash

echo "--------------------------------------------------"
echo "   Installing Vortex OS Core & S_12 Security      "
echo "--------------------------------------------------"

pacman -Syu --noconfirm
pacman -S --noconfirm \
    hyprland waybar rofi-wayland kitty fastfetch git base-devel \
    ttf-jetbrains-mono ttf-font-awesome plymouth sddm \
    firefox dolphin ark p7zip unrar lxappearance pavucontrol \
    kpmcore ufw fail2ban debugedit fakeroot


if [ "$(id -u)" -eq 0 ]; then
    if ! id "build" &>/dev/null; then
        useradd -m build
        echo "build ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
    fi
fi

# 3. تثبيت YAY (مساعد AUR)
if ! command -v yay &> /dev/null; then
    echo "Installing YAY (AUR Helper)..."
    rm -rf /tmp/yay
    su build -c "git clone https://aur.archlinux.org/yay.git /tmp/yay && cd /tmp/yay && makepkg -si --noconfirm"
fi


echo "Installing Calamares Installer & Tools from AUR..."
su build -c "yay -S --noconfirm calamares awww-git bauh"

# 5. تجهيز مسارات الإعدادات
TARGET_HOME="${HOME}"
if [ "$USER" = "root" ] && [ -d "/home/liveuser" ]; then
    TARGET_HOME="/home/liveuser"
fi

mkdir -p "$TARGET_HOME/.config/hypr/backgrounds"
mkdir -p "$TARGET_HOME/.config/waybar"
mkdir -p "$TARGET_HOME/.config/fastfetch"

 
[ -f "hyprland.conf" ] && cp hyprland.conf "$TARGET_HOME/.config/hypr/"
[ -f "waybar-config.jsonc" ] && cp waybar-config.jsonc "$TARGET_HOME/.config/waybar/"
[ -f "style.css" ] && cp style.css "$TARGET_HOME/.config/waybar/"
[ -d "fastfetch" ] && cp -r fastfetch/* "$TARGET_HOME/.config/fastfetch/"
[ -d "backgrounds" ] && cp -r backgrounds/* "$TARGET_HOME/.config/hypr/backgrounds/"


if [ -f "s12-sec" ]; then
    chmod +x s12-sec
    cp s12-sec /usr/local/bin/
fi


echo "Activating S_12 Security Shield..."
systemctl enable ufw
ufw default deny incoming
ufw default allow outgoing
echo "y" | ufw enable
systemctl enable fail2ban
        

if [ -f "$TARGET_HOME/.bashrc" ]; then
    if ! grep -q "fastfetch" "$TARGET_HOME/.bashrc"; then
        echo "fastfetch" >> "$TARGET_HOME/.bashrc"
    fi
fi


mkdir -p /usr/share/plymouth/themes/vortex
[ -f "vortex.plymouth" ] && cp vortex.plymouth /usr/share/plymouth/themes/vortex/
[ -f "vortex.script" ] && cp vortex.script /usr/share/plymouth/themes/vortex/

if command -v plymouth-set-default-theme &> /dev/null; then
    plymouth-set-default-theme -R vortex
fi

if ! grep -q "plymouth" /etc/mkinitcpio.conf; then
    sed -i 's/HOOKS=(/HOOKS=(plymouth /' /etc/mkinitcpio.conf
    mkinitcpio -P
fi


if [ -d "calamares" ]; then
    mkdir -p /usr/share/calamares/branding/
    cp -r calamares/branding/vortex /usr/share/calamares/branding/
fi


systemctl enable sddm

echo "--------------------------------------------------"
echo "   Vortex OS & S_12 Shield Ready! Restart now.    "
echo "--------------------------------------------------"
