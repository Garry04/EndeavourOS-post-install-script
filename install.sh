#!/bin/bash

############################
##ENDEAVOUR INSTALL SCRIPT##
############################
# By Garry



version="0.1"

c1="\e[38;5;63m"
gray="\e[38;5;242m"
green='\033[0;32m'
white='\033[0m'
red="\e[31m"
resetC="\e[0m"

#ascii art by dylanaraps
endeavour_logo="
      ${c1}/\\
    ${c1}//  \\
   ${c1}//    \\
 ${c1}/ ${c1}/     _)
${c1}/_${c1}/___-- __-
 ${c1}/____--
\e[0m"

arch_logo="

${c1}       /\\
${c1}      /  \\
${c1}     /\\  \\
${c1}    /      \\
${c1}   /   ,,   \\
${c1}  /   |  |  -\\
${c1} /_-''    ''-_\\
\e[0m"

username=$(whoami)
echo "Hello, $username :3"
echo -e "${gray}$version"
sleep 0.5

if [ -e /etc/os-release ]; then
    source /etc/os-release
    if [ "$ID" == "endeavouros" ]; then
        echo -e "$endeavour_logo"
    else
        # Message for other distributions
        echo -e "\e[1;31mEndeavourOS wasn't detected! This script hasnt been tested on other Arch based distributions use at your own risk.\e[0m"
        echo -e "$arch_logo"
    fi
else
    echo -e "\e[1;31mEndeavourOS wasn't detected! This script hasnt been tested on other Arch based distributions use at your own risk.\e[0m"
fi

# add nvidia support
# Check if NVIDIA GPU is present
if lspci | grep -i nvidia &> /dev/null; then
    echo -e "\e[1;31mNVIDIA GPU detected, no nvidia drivers were installed currently working on adding this meanwhile please go to https://wiki.archlinux.org/title/NVIDIA\e[0m"
    echo "Script will continue in 8 seconds."
    sleep 8
    # Add your NVIDIA-specific commands here
elif lspci | grep -i amd &> /dev/null; then
    echo "AMD GPU detected, installing drivers..."
    sudo pacman -S vulkan-radeon lib32-vulkan-radeon lib32-mesa mesa libva-mesa-driver


else
    echo "No NVIDIA or AMD GPU detected."
fi
clear
installParu() {
    echo "Installing paru..."
    # Add the command to install paru here
    sudo pacman -S --needed base-devel
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si
}

# Function to install yay
installYay() {
    echo "Installing yay..."
    # Add the command to install yay here
    sudo pacman -S yay
}

#################################
# Function to select AUR helper #
#################################

selectAurHelper() {
    local aur_choice
    local aur_installed

    while true; do
        echo "Choose AUR helper:"
        echo -e "${gray}Default (1)${resetC}"
        echo -e "1. paru - ${gray}Written in Rust, a memory-safe language${resetC}"
        echo -e "2. yay - ${gray}Written in Go${resetC}"
        echo "3. I already have one"

        read -r -p "(1-3): " aur_choice

        if [[ -z "$aur_choice" ]]; then
            aur_choice=1
        fi

        case $aur_choice in
            1)
                aur_installed="paru"
                if ! command -v paru &> /dev/null; then
                    installParu
                else
                    clear
                    echo "paru is already installed."
                fi
                ;;
            2)
                aur_installed="yay"
                if ! command -v yay &> /dev/null; then
                    installYay
                else
                    echo "yay is already installed."
                fi
                ;;
            3)
                # Detect which AUR helper is already installed
                if command -v yay &> /dev/null && command -v paru &> /dev/null; then
                    clear
                    echo "Both yay and paru are installed. Defaulting to paru."
                    aur_installed="paru"
                elif command -v yay &> /dev/null; then
                    clear
                    echo "Pay was detected."
                    aur_installed="yay"
                elif command -v paru &> /dev/null; then
                    clear
                    echo "Paru was detected."
                    aur_installed="paru"
                else
                    echo -e "${red}No AUR helper detected.${resetC}"
                fi
                ;;
            *)
                clear
                echo -e "${red}Invalid choice for AUR helper.${resetC}"
                ;;
        esac

        if [[ -n "$aur_installed" ]]; then
            break
        else
            echo -e "${red}Please choose a valid AUR helper.${resetC}"
        fi
    done
    aur="$aur_installed"
   
}

# Call the function to select AUR helper
selectAurHelper

echo "Selected AUR helper: $aur"
sleep 1.5

clear

######################################################
# Function to install a terminal based on user choice#
######################################################

install_terminal() {
    case $1 in
        1)
            echo "Installing xterm..."
            sudo pacman -S xterm
            ;;
        2)
            echo "Installing kitty..."
            sudo pacman -S kitty
            ;;
        3)
            echo "Installing alacritty..."
            sudo pacman -S alacritty
            mv alacritty.yml "/home/$USER/.config/alacritty/"
            ;;
        4)
            echo "No terminal was installed."
            ;;
        *)
            clear
            echo -e "${red}Invalid choice. Please choose a valid option (1-4).${resetC}"
            return 1
            ;;
    esac
}

# Loop to handle invalid choices
while true; do
    # Display menu to the user
    echo "Select a terminal to install:"
    echo "1. xterm"
    echo "2. kitty"
    echo "3. alacritty"
    echo "4. none"

    # Read user input
    read -r -p "Enter the number of your choice: " choice

    # Call the install_terminal function with the user's choice
    install_terminal "$choice"

    # Check the return value of install_terminal
    if [ $? -eq 0 ]; then
        break  # Break the loop if a valid choice is made
    fi
done



clear
# Function to install network tools
install_tool() {
    tool=$1
    sudo pacman -S --noconfirm "$tool"
    echo "$tool installed successfully."
}

while true; do
    read -r -p "Do you want to install network tools? (y/n): " install_choice

    # Default to "y" if the user presses Enter without providing any input
    install_choice=${install_choice:-"y"}

    if [[ $install_choice == "y" ]]; then
        while true; do
            echo "Select the tools you want to install:"
            echo " "
            echo "1. ALL"
            echo "2. Nmap"
            echo "3. Bettercap"
            echo "4. Wireshark"

            read -r -p "Enter the numbers of the tools you want to install (e.g., 1 2, 3): " choices

            if [[ -z $choices ]]; then
                # If the user presses Enter with no input, default to installing the first option
                choices="1"
            fi

            invalid_input=false
            choices_arr=($choices)
            for choice in "${choices_arr[@]}"; do
                case $choice in
                    1) sudo pacman -S --noconfirm nmap bettcap wireshark-qt ;;
                    2) install_tool "nmap" ;;
                    3) install_tool "bettercap" ;;
                    4) install_tool "wireshark-qt" ;;
                    *) clear ; echo "Invalid choice: $choice." ; invalid_input=true ;;
                esac
            done

            if [[ "$invalid_input" == false ]]; then
                echo "Network tools installation complete."
                break
            else
                clear
                echo "Please provide valid input."
            fi
        done
        break
    elif [[ $install_choice == "n" ]]; then
        echo "Skipping network tools installation."
        break
    else
        clear
        echo "Invalid input. Please enter 'y' or 'n'."
    fi
done



# Array of packages to install
packages=("lutris" "vlc" "neofetch" "kfind" "flameshot" "curl" "wget" "tar")

parPack=( "qbittorrent" "discord" "librewolf" "heroic-games-launcher" "protonup-qt" "timeshift-autosnap")

sudo pacman -Syyu

# Install required packages
for package in "${packages[@]}"; do
    sudo pacman -S --noconfirm "$package"
done

for package in "${parPack[@]}"; do
    $aur -S --noconfirm "$package"
done

echo "Packages installed successfully!"
sleep .5
echo "Now applying config"


##########################
#INSTALLING SECURITY SHIT#
##########################
echo "Installing firewall..."
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if ufw is installed
if command_exists ufw; then
    echo "ufw is already installed."
else
    echo "ufw is not installed. Installing ufw..."
    sudo pacman -S --noconfirm ufw gufw
fi

# Check if firewalld is installed
if command_exists firewalld; then
    echo "firewalld is already installed."
else
    echo "firewalld is not installed. Installing firewalld..."
    sudo pacman -S --noconfirm firewalld
    sudo systemctl enable --now firewalld
fi
echo "Installing ldns for secure dns servers..."
sudo pacman -S --noconfirm rkhunter ldns
echo "Firewall setup complete."
clear

###################
#INSTALLING KERNEL#
###################
promptCachyOSRepo() {
    clear
    read -r -p "The CachyOS Kernel includes its repository. Do you want to include the CachyOS repository? (y/n): " include_repo

    if [ "$include_repo" == "y" ]; then
        echo "Installing CachyOS kernel & repository..."
        wget https://mirror.cachyos.org/cachyos-repo.tar.xz
        tar xvf cachyos-repo.tar.xz && cd cachyos-repo
        sudo ./cachyos-repo.sh
    else
        echo "Skipping CachyOS repository inclusion."
        sleep 0.1
        clear
        chooseKernel
    fi
}

chooseKernel() {
    local kernel_choice

    while true; do
        echo "Choose an additional kernel to install:"
        echo -e "1. Nobara - ${gray}A performance-focused kernel with cherry-picked patches from zen and tkg.\e[0m"
        echo -e "2. Zen - ${gray}Optimized for desktop and gaming usage.\e[0m"
        echo -e "3. Liquorix - ${gray}Designed for low-latency and multimedia production.\e[0m"
        echo -e "4. CachyOS - ${gray}A gaming-oriented kernel with extra optimizations.\e[0m"
        echo -e "5. None - ${gray}Wont install anything.\e[0m"

        read -r -p "Enter the number of the kernel you want to install (1-5): " kernel_choice

        case $kernel_choice in
            1)
                echo "Installing Nobara Kernel..."
                $aur -S linux-fsync-nobara-bin
                ;;
            2)
                echo "Installing Zen Kernel..."
                sudo pacman -S linux-zen linux-zen-headers
                ;;
            3)
                echo "Installing Liquorix Kernel..."
                curl -s 'https://liquorix.net/install-liquorix.sh' | sudo bash
                ;;
            4)
                echo "Installing CachyOS Kernel..."
                promptCachyOSRepo
                ;;
            5)
                echo "No kernel was installed."
                ;;
            *)
                clear
                echo -e "${red}Invalid choice. Please choose a valid option (1-5).${resetC}"
                ;;
        esac
    done
}

read -r -p "Do you want to install an additional kernel? (y/n): " proceed_to_kernel

if [ "$proceed_to_kernel" == "y" ]; then
    clear
    chooseKernel
else
    echo "Continuing with the rest of the script."
fi

confBash() {
    echo "Installing Bash configuration..."
    mv .bashrc "/home/$USER/"
    $aur -S --noconfirm eza ugrep

}

confWall() {
    echo "Installing Wallpapers in /Pictures/Wallpapers..."
    sleep 0.5
    mv Wallpapers "/home/$USER/Pictures/"
    mv plasma-org.kde.plasma.desktop-appletsrc "/home/$USER/.config/"
#                qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript '
 #                   var allDesktops = desktops();
  #                  print (allDesktops);
   ##                    d = allDesktops[i];
     #                   d.wallpaperPlugin = "org.kde.image";
      #                  d.currentConfigGroup = Array("Wallpaper",
       #                                             "org.kde.image",
        #                                            "General");
         #               d.writeConfig("Image", "file:/home/$USER/Pictures/Wallpapers/wallhaven_T5_Shizuka_Hoshijiro.png")
          #          }}
           #     '

}

confDesktop() {
    echo "Installing Full customization..."
    echo "Applying kwin settings & taskbar settings..."
    echo "Installing Desktop..."
    mv kwinrc "/home/$USER/.config/"
    mv plasma-org.kde.plasma.desktop-appletsrc "/home/$USER/.config/"
    mv Carl.colors "/home/$USER/.local/share/color-schemes"
    echo "Installing icons..."
    $aur -S --noconfirm eza ugrep
    $aur -S --noconfirm kora-icon-theme
}

confStarship() {
    echo "Installing Starship shell configuration..."
    sudo pacman -S --no-comfirm starship
    mv starship.toml "/home/$USER/.config/"

}
confNeofetch() {
    echo "Installing neofetch configuration..."
    mv config.conf "/home/$USER/.config/neofetch/"
}

#install config
while true; do
    clear
    echo "Choose customization options (e.g., 1, 2 3):"
    echo -e "1. Full ${red}(KDE)- ${gray}install everything${resetC}"
    echo -e "2. Bash config - ${gray}installs custom bashrc with improved ls and aliases${resetC}"
    echo -e "3. Wallpapers - ${gray}installs a few wallpapers${resetC}"
    echo -e "4. Desktop ${red} - ${gray}installs my kde desktop config, conky, taskbar etc..${resetC}"
    echo -e "5. starship shell - ${gray}installs a custom starship shell"
    echo -e "6. neofetch config - ${gray}installs a custom neofetch config${resetC}"

    read -r -p "Enter the numbers of the customization options you want to install (1-6): " customization_choices

    # Check if all choices are valid
    valid_choices=true
    for choice in $customization_choices; do
        if [[ ! $choice =~ ^[1-4]$ ]]; then
            echo -e "\e[1;31mInvalid choice '$choice'. Please enter valid numbers between 1 and 4, separated by spaces.\e[0m"
            valid_choices=false
            break
        fi
    done

    if [ "$valid_choices" = false ]; then
        continue
    fi

    # Check if "Full" is selected along with any other options
    if [[ $customization_choices == *"1"* && $customization_choices != "1" ]]; then
        echo -e "\e[1;31mCannot select 'Full' along with other options. Please choose again.\e[0m"
        continue
    fi

    # Process selected customization options
    for choice in $customization_choices; do
        case $choice in
            1)
                confBash
                confWall
                confDesktop
                confStarship
                confNeofetch
                ;;
            2)
                confBash
                ;;
            3)
                confWall
                ;;
            4)
                confDesktop
                ;;
            5)
                confStarship
                ;;
            6)
                confNeofetch
                ;;

        esac
    done

    echo "Customization installation complete."
    break
done


echo "Installed successfully!"

read -r -p "You need to reboot to apply changes, do you want to reboot now? (y/n): " answer

if [ "$answer" == "y" ]; then
    echo "Rebooting..."
    reboot
else
    echo "You chose not to reboot. Changes will take effect after the next restart."
fi
