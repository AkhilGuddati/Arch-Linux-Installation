#!/bin/bash

# Define the default values
MODE="dark"
COLOURSCHEME="scheme-tonal-spot"
WALL=""
BACK=" Back"
WALLPAPERS=$(find ~/Pictures/Wallpapers -type f -name "*.jpg" -or -name "*.png")
Theme="$HOME/.config/rofi/matugen.rasi"

# Function to display the main menu
main_menu() {
    menu=$(echo -e "Mode\nColour-Scheme\nWallpaper\nApply" | rofi -dmenu -p "Matugen" -theme $Theme)

    case $menu in
        "Mode")
            # Open dmenu for light/dark mode and set the selected option
            mode_choice=$(echo -e "light\ndark\n$BACK" | rofi -dmenu -p "Select Mode" -theme $Theme)
            if [[ -z "$mode_choice" ]]; then
                return 0  # Exit if no choice is made
            elif [[ "$mode_choice" = "$BACK" ]]; then
                main_menu  # Go back to the main menu
            else
                MODE=$mode_choice
                echo "selected $MODE"
                main_menu
            fi
            ;;
        "Colour-Scheme")
            # Open dmenu for colour-scheme and set the selected option
            colour_choice=$(echo -e "scheme-content\nscheme-expressive\nscheme-fidelity\nscheme-fruit-salad\nscheme-monochrome\nscheme-neutral\nscheme-rainbow\nscheme-tonal-spot\n$BACK" | rofi -dmenu -p "Select Colour-Scheme" -theme $Theme)
            if [[ -z "$colour_choice" ]]; then
                return 0  # Exit if no choice is made
            elif [[ "$colour_choice" = "$BACK" ]]; then
                main_menu  # Go back to the main menu
            else
                COLOURSCHEME=$colour_choice
                echo "selected $COLOURSCHEME"
                main_menu
            fi
            ;;
        "Wallpaper")
            # Open a menu with all images in Pictures/Wallpapers
            wallpaper_choice=$(echo -e "$WALLPAPERS\n$BACK" | rofi -dmenu -p "Select Wallpaper" -theme $Theme)
            if [[ -z "$wallpaper_choice" ]]; then
                return 0  # Exit if no choice is made
            elif [[ "$wallpaper_choice" = "$BACK" ]]; then
                main_menu  # Go back to the main menu
            else
                WALL=$wallpaper_choice
                echo "selected $WALL"
                main_menu
            fi
            ;;
        "Apply")
             if [ -n "$WALL" ]; then
                # Apply wallpaper and configuration sequentially
                swww img "$WALL" --transition-fps 30 --transition-step 30 && \
                matugen -m $MODE -t $COLOURSCHEME image "$WALL" && \
                magick "$WALL" -resize 640x360 -quality 10 "$HOME/.config/current_wall.png" && \
                gsettings set org.gnome.desktop.interface color-scheme "prefer-$MODE" && \
                makoctl reload && \
                exec $HOME/.config/hypr/scripts/folder_color.sh && \
                echo "Matugen Done" && \
                pkill -SIGUSR2 waybar
            else
                echo "No wallpaper selected."
            fi
            ;;
        *)
            echo "Invalid option selected."
            ;;
    esac
}

main_menu
