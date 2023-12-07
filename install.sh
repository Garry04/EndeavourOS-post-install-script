#!/bin/bash
c1="\e[38;5;63m"
gray="\e[38;5;242m"

endeavour_logo="
      ${c1}/\\
    ${c1}//  \\
   ${c1}//    \\
 ${c1}/ ${c1}/     _)
${c1}/_${c1}/___-- __-
 ${c1}/____--
\e[0m"

echo -e "$endeavour_logo"



username=$(whoami)
echo "Hello, $username :3"
echo -e "${gray}Version 0.1"
sleep 0.2

if [ -e /etc/os-release ]; then
    source /etc/os-release
    if [ "$ID" == "endeavouros" ]; then
        echo " "
    else
        # Message for other distributions
        echo -e "\e[1;31mEndeavourOS wasn't detected! This script hasnt been tested on other Arch based distributions use at your own risk.\e[0m"
    fi
else
    echo "\e[1;31mEndeavourOS wasn't detected! This script hasnt been tested on other Arch based distributions use at your own risk.\e[0m"
fi

# add nvidia support
# Check if NVIDIA GPU is present
if lspci | grep -i nvidia &> /dev/null; then
    echo "\e[1;31mNVIDIA GPU detected, no nvidia drivers were installed currently working on adding this meanwhile please go to https://wiki.archlinux.org/title/NVIDIA\e[0m"
    sleep 8
    # Add your NVIDIA-specific commands here
elif lspci | grep -i amd &> /dev/null; then
    echo "AMD GPU detected, installing drivers..."
    sudo pacman -S vulkan-radeon lib32-vulkan-radeon lib32-mesa mesa libva-mesa-driver


else
    echo "No NVIDIA or AMD GPU detected."
fi


# Select the AUR helper
echo "Choose AUR helper:"
echo "1. paru (recommended)"
echo "2. yay"

read -p "Enter the number of the AUR helper you want to use (1-2): " aur_choice

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
read -p "Enter the number of your choice: " choice

# Call the install_terminal function with the user's choice
install_terminal $choice



# Function to install network tools
install_tool() {
    tool=$1
    sudo pacman -S --noconfirm $tool
    echo "$tool installed successfully."
}

read -p "Do you want to install network tools? (y/n): " install_choice

if [[ $install_choice == "y" ]]; then
    echo "Select the tools you want to install:"
    echo "1. nmap"
    echo "2. bettercap"
    echo "3. wireshark"
    echo "4. bettercap"

    read -p "Enter the numbers of the tools you want to install (e.g., 1 2, 3): " choices

    choices_arr=($choices)
    for choice in "${choices_arr[@]}"; do
        case $choice in
            1) install_tool "nmap" ;;
            2) install_tool "bettercap" ;;
            3) install_tool "wireshark-qt" ;;
            4) install_tool "bettercap"
            *) echo "Invalid choice: $choice. Skipping." ;;
        esac
    done

    echo "Network tools installation complete."
else
    echo "Skipping network tools installation"
fi



# Array of packages to install
packages=("lutris" "vlc" "neofetch" "kfind" "ufw" "gufw" "rkhunter" "flameshot" "starship" "mesa" "curl" "wget" "tar")

parPack=( "qbittorrent" "discord" "librewolf" "heroic-games-launcher" "protonup-qt" "timeshift-autosnap")

# Update package database
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

#install config
while true; do
    echo "Choose customization options (enter the corresponding numbers, separate with spaces):"
    echo "1. Full - install everything"
    echo "2. Bash config - installs custom bashrc with improved ls and aliases"
    echo "3. Wallpapers - installs a few wallpapers"
    echo "4. Desktop - installs my kde desktop config, conky, taskbar etc.."
    echo "5. starship shell - installs a custom starship shell"
    echo "6. neofetch config - installs a custom neofetch config"

    read -p "Enter the numbers of the customization options you want to install (1-6): " customization_choices

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
                # Add commands for full customization...
                ;;
            2)
                echo "Installing Bash config..."
                mv .bashrc "/home/$USER/"
                ;;
            3)
                echo "Installing Wallpapers..."
                mv Wallpapers "/home/$USER/Pictures/"
                qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript '
                    var allDesktops = desktops();
                    print (allDesktops);
                    for (i=0;i<allDesktops.length;i++) {{
                        d = allDesktops[i];
                        d.wallpaperPlugin = "org.kde.image";
                        d.currentConfigGroup = Array("Wallpaper",
                                                    "org.kde.image",
                                                    "General");
                        d.writeConfig("Image", "file:/home/$USER/Pictures/Wallpapers/wallhaven_T5_Shizuka_Hoshijiro.png")
                    }}
                '
                ;;
            4)
                echo "Installing Desktop..."
                # Add commands for desktop...
                ;;
            5)
                echo "Installing starship shell..."
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
#mv .bashrc "/home/$USER/"
#mv config.conf "/home/$USER/.config/neofetch/"
#mv starship.toml "/home/$USER/.config/"
#mv Wallpapers "/home/$USER/Pictures/"

#apply wallpaper





echo "Installed successfully!"
echo "Reboot to apply changes."
