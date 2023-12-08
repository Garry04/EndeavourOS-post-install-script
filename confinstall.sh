#!/bin/bash


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
                mv kwinrc "/home/$USER/.config/"
                mv plasma-org.kde.plasma.desktop-appletsrc "/home/$USER/.config/"
                mv starship.toml "/home/$USER/.config/"
                mv config.conf "/home/$USER/.config/neofetch/"
                mv Wallpapers "/home/$USER/Pictures/"
                ;;
            2)
                echo "Installing Bash config..."
                mv .bashrc "/home/$USER/"
                $aur -S --noconfirm eza ugrep

                ;;
            3)
                echo "Installing Wallpapers..."
                mv Wallpapers "/home/$USER/Pictures/"
                mv plasma-org.kde.plasma.desktop-appletsrc "/home/$USER/.config/"
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
            4)s
                echo "Installing Desktop..."
                mv kwinrc "/home/$USER/.config/"
                mv plasma-org.kde.plasma.desktop-appletsrc "/home/$USER/.config/"
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
