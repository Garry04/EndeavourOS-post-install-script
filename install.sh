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
sleep 0.2

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

# Select the AUR helper
echo "Choose AUR helper:"
echo "1. paru (recommended)"
echo "2. yay"

read -r -p "Enter the number of the AUR helper you want to use (1-2): " aur_choice

if [[ -z "$aur_choice" ]]; then
    aur_choice=1
fi

case $aur_choice in
    1)
        aur="paru"
        if ! command -v paru &> /dev/null; then
            echo "Installing paru..."
            # Add the command to install paru here
            sudo pacman -S --needed base-devel
            git clone https://aur.archlinux.org/paru.git
            cd paru 
            makepkg -si
        else
            echo "paru is already installed."
        fi
        ;;
    2)
        aur="yay"
        if ! command -v yay &> /dev/null; then
            echo "Installing yay..."
            # Add the command to install yay here
            sudo pacman -S yay
        else
            echo "yay is already installed."
        fi
        ;;
    *)
        echo "Invalid choice for AUR helper. Exiting."
        exit 1
        ;;
esac

clear
# Function to install a terminal based on user choice
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
            echo "Installing alacrtity..."
            sudo pacman -S alacritty
            mv alacritty.yml "/home/$USER/.config/alacritty/"
            ;;
        4)
            echo "No terminal was installed"
            ;;
        *)
            echo "Invalid choice. No terminal installed."
            ;;
    esac
}

# Display menu to the user
echo "Select a terminal to install:"
echo "1. xterm"
echo "2. kitty"
echo "3. alacritty"
echo "4. none"

# Read user input
read -r -p "Enter the number of your choice: " choice

# Call the install_terminal function with the user's choice
install_terminal $choice


clear
# Function to install network tools
install_tool() {
    tool=$1
    sudo pacman -S --noconfirm $tool
    echo "$tool installed successfully."
}

read -r -p "Do you want to install network tools? (y/n): " install_choice

if [[ $install_choice == "y" ]]; then
    echo "Select the tools you want to install:"
    echo "1. nmap"
    echo "2. bettercap"
    echo "3. wireshark"

    read -r -p "Enter the numbers of the tools you want to install (e.g., 1 2, 3): " choices

    choices_arr=($choices)
    for choice in "${choices_arr[@]}"; do
        case $choice in
            1) install_tool "nmap" ;;
            2) install_tool "bettercap" ;;
            3) install_tool "wireshark-qt" ;;
            *) echo "Invalid choice: $choice. Skipping." ;;
        esac
    done

    echo "Network tools installation complete."
else
    echo "Skipping network tools installation"
fi



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


#install config
while true; do
    clear
    echo "Choose customization options (enter the corresponding numbers, separate with spaces):"
    echo -e "1. Full - install everything"
    echo -e "2. Bash config - installs custom bashrc with improved ls and aliases"
    echo -e "3. Wallpapers - installs a few wallpapers"
    echo -e "4. Desktop - installs my kde desktop config, conky, taskbar etc.."
    echo -e "5. starship shell - installs a custom starship shell"
    echo -e "6. neofetch config - installs a custom neofetch config"

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
                echo "Installing Full customization..."

                echo "Applying kwin settings & taskbar settings..."
                mv kwinrc "/home/$USER/.config/"
                mv plasma-org.kde.plasma.desktop-appletsrc "/home/$USER/.config/"
                echo "Applying all terminal configs..."
                sudo pacman -S starship
                mv starship.toml "/home/$USER/.config/"
                mv .bashrc "/home/$USER/"
                mv config.conf "/home/$USER/.config/neofetch/"
                echo "Installing wallpapers in /Pictures/Wallpapers..."
                sleep 0.2
                mv Wallpapers "/home/$USER/Pictures/"
                #qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript '
                #    var allDesktops = desktops();
                #    print (allDesktops);
                #    for (i=0;i<allDesktops.length;i++) {{
                #        d = allDesktops[i];
                #        d.wallpaperPlugin = "org.kde.image";
                #        d.currentConfigGroup = Array("Wallpaper",
                #                                    "org.kde.image",
                #                                    "General");
                #        d.writeConfig("Image", "file:/home/$USER/Pictures/Wallpapers/wallhaven_T5_Shizuka_Hoshijiro.png")
                #    }}
                #'
                echo "Applying color scheme..."
                mv Carl.colors "/home/$USER/.local/share/color-schemes"
                echo "Installing icons..."
                $aur -S --noconfirm eza ugrep
                $aur -S --noconfirm kora-icon-theme
                ;;
            2)
                echo "Installing Bash config..."
                mv .bashrc "/home/$USER/"
                $aur -S --noconfirm eza ugrep

                ;;
            3)
                echo "Installing Wallpapers in /Pictures/Wallpapers..."
                sleep 0.2
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
                ;;
            4)s
                echo "Installing Desktop..."
                mv kwinrc "/home/$USER/.config/"
                mv plasma-org.kde.plasma.desktop-appletsrc "/home/$USER/.config/"
                ;;
            5)
                echo "Installing starship shell config..."
                sudo pacman -S --no-comfirm starship
                mv starship.toml "/home/$USER/.config/"
                ;;
            6)
                echo "Installing neofetch config..."
                mv config.conf "/home/$USER/.config/neofetch/"
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
