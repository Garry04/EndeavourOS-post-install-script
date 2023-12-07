#!/bin/bash
gray="\e[38;5;242m"

# Function to install packages and execute commands
gamingTweaks() {
    # Install packages using paru (or pacman if paru is not available)
    #paru -S --needed "package1" "package2" "package3" || sudo pacman -S --needed "package1" "package2" "package3"

    echo "Choose a kernel to install (enter the corresponding number):"
    echo -e "1. Nobara - ${gray}A performance-focused kernel with cherry picked patches from zen and tkg.\e[0m"
    echo -e "2. Zen - ${gray}Optimized for desktop and gaming usage.\e[0m"
    echo -e "3. Liquorix - ${gray}Designed for low-latency and multimedia production.\e[0m"
    echo -e "4. CachyOS - ${gray}A gaming-oriented kernel with extra optimizations.\e[0m"
    echo -e "5. None - ${gray}Use default kernel.\e[0m"

    # Prompt user to choose a kernel
    read -p "Enter the number of the kernel you want to install (1-4): " kernel_choice

    case $kernel_choice in
        1)
            echo "Installing Nobara Kernel..."
            $aur -S linux-fsync-nobara-bin
        2)
            echo "Installing Zen Kernel..."
            sudo pacman -S linux-zen linux-zen-headers
            ;;
        3)
            curl -s 'https://liquorix.net/install-liquorix.sh' | sudo bash
            ;;
        4)
            echo "Installing CachyOS Kernel..."
            wget https://mirror.cachyos.org/cachyos-repo.tar.xz
            tar xvf cachyos-repo.tar.xz && cd cachyos-repo
            sudo ./cachyos-repo.sh
            ;;
        5)
            echo "No kernel was installed."
            ;;
        *)
            echo "Invalid choice. No kernel will be installed."
            ;;
    esac


}

# Prompt user to execute the function
read -p "Do you want to install tweaks to improve performance and latency?(y/n)" execute_choice

if [ "$execute_choice" == "y" ]; then
    # Call the function if the user chooses "yes"
    gamingTweaks
else
    echo "Continuing with the rest of the script."
fi

# Continue with the rest of your script...
