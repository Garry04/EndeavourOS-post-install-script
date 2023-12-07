#!/bin/bash

username=$(whoami)
echo "Hello, $username :3"
sleep 0.2
echo -e "\e[1;31mThis script is only made for EndeavourOS use at your own risk of ur running it on other Arch distros.\e[0m"
sleep 1

# install paru
sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

# Array of packages to install
packages=("lutris" "vlc" "neofetch" "alacritty" "kfind" "ufw" "gufw" "rkhunter" "flameshot" "starship" "mesa") 

parPack=("blender" "qbittorrent" "discord" "librewolf" "blender" "heroic-games-launcher" "protonup-qt")

# Update package database
sudo pacman -Syyu

# Install required packages
for package in "${packages[@]}"; do
    sudo pacman -S --noconfirm "$package"
done

for package in "${parPack[@]}"; do
    paru -S --noconfirm "$package"
done

echo "Packages installed successfully!"
sleep .5
echo "Now applying config"

#install config
mv .bashrc "/home/$USER/"
mv config.conf "/home/$USER/.config/neofetch/"
mv alacritty.yml "/home/$USER/.config/alacritty/"
mv starship.toml "/home/$USER/.config/"

echo "Config installed successfully!"
echo "Reboot to apply changes"
