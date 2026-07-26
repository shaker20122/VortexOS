#!/bin/bash

echo "--------------------------------------------------"
echo "   Installing Vortex OS Core & S_12 Security      "
echo "--------------------------------------------------"

# 1. Update system and install base packages via pacman
sudo pacman -Syu --noconfirm
sudo pacman -S --noconfirm \
    hyprland waybar rofi-wayland kitty fastfetch git base-devel \
    ttf-jetbrains-mono ttf-font-awesome plymouth sddm \
    firefox dolphin ark p7zip unrar lxappearance pavucontrol neofetch \
    calamares kpmcore ufw fail2ban

# 2. Install YAY (AUR Helper) if not present
if ! command -v yay &> /dev/null; then
    echo "Installing YAY (AUR Helper)..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay && makepkg -si --noconfirm
    cd - && rm -rf /tmp/yay
fi

# 3. Install GUI App Store & Background Daemon via AUR
echo "Installing Software Center & Tools..."
yay -S --noconfirm awww-git bauh

# 4. Create Directory Structure in user home config
mkdir -p ~/.config/hypr/backgrounds
mkdir -p ~/.config/waybar
mkdir -p ~/.config/fastfetch

# 5. Copy Configuration Files
cp hyprland.conf ~/.config/hypr/
cp waybar-config.jsonc ~/.config/waybar/
cp style.css ~/.config/waybar/
cp -r fastfetch/* ~/.config/fastfetch/
cp -r backgrounds/* ~/.config/hypr/backgrounds/

# 6. Setup S_12 Security Tool
if [ -f "s12-sec" ]; then
    chmod +x s12-sec
    sudo cp s12-sec /usr/local/bin/
fi

# 7. Enable & Configure S_12 Security Engine (UFW & Fail2ban)
echo "Activating S_12 Security Shield..."
sudo systemctl enable ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable
sudo systemctl enable fail2ban

# 8. Set Fastfetch to run on shell startup
if ! grep -q "fastfetch" ~/.bashrc; then
    echo "fastfetch" >> ~/.bashrc
fi

# 9. Setup Plymouth Boot Theme
sudo mkdir -p /usr/share/plymouth/themes/vortex
sudo cp vortex.plymouth /usr/share/plymouth/themes/vortex/
sudo cp vortex.script /usr/share/plymouth/themes/vortex/
sudo plymouth-set-default-theme -R vortex

if ! grep -q "plymouth" /etc/mkinitcpio.conf; then
    sudo sed -i 's/HOOKS=(/HOOKS=(plymouth /' /etc/mkinitcpio.conf
    sudo mkinitcpio -P
fi

# 10. Setup Calamares Installer Branding
if [ -d "calamares" ]; then
    sudo mkdir -p /usr/share/calamares/branding/
    sudo cp -r calamares/branding/vortex /usr/share/calamares/branding/
fi

# 11. Enable SDDM Login Manager
sudo systemctl enable sddm

echo "--------------------------------------------------"
echo "   Vortex OS & S_12 Shield Ready! Restart now.    "
echo "--------------------------------------------------"