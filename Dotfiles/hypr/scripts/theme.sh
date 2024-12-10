#!/bin/bash

# Define the default values
MODE="dark"
WALL=""
PYWAL="wal --cols16 -i $WALL"
BACK=" Back"
WALLPAPERS_DIR="$HOME/Pictures/Wallpapers"
GRID_ROWS=${GRID_ROWS:-3}
GRID_COLS=${GRID_COLS:-3}
ICON_SIZE=${ICON_SIZE:-15}
Theme="$HOME/.config/rofi/pywal.rasi"

build_theme() {
    rows=$1
    cols=$2
    icon_size=$3

    echo "window{width:900px;}element{orientation:vertical;}element-text{horizontal-align:0.5;}element-icon{size:$icon_size.0000em;horizontal-align:0.5;vertical-align:0.5;}listview{lines:$rows;columns:$cols;}"
}

# Function to display the main menu
main_menu() {
    menu=$(echo -e "Mode\nWallpaper\nApply" | rofi -dmenu -p "Pywal" -theme $Theme)

    case $menu in
        "Mode")
            # Open dmenu for light/dark mode and set the selected option
            mode_choice=$(echo -e "Light\nDark\n$BACK" | rofi -dmenu -p "Select Mode" -theme $Theme)
            if [[ -z "$mode_choice" ]]; then
                return 0
            elif [[ "$mode_choice" = "Dark" ]]; then
                MODE="dark"
                main_menu
            elif [[ "$mode_choice" = "Light" ]]; then
                MODE="light"
                main_menu
            elif [[ "$mode_choice" = "$BACK" ]]; then
                main_menu
            else
                MODE=$mode_choice
                echo "selected $MODE"
                main_menu
            fi
            ;;
        "Wallpaper")
            images=$(find "$WALLPAPERS_DIR" -type f -maxdepth 1 -printf "%T@ %f\x00icon\x1f$WALLPAPERS_DIR/%f\n" | sort -rn | cut -d' ' -f2-)
            wallpaper_choice=$(echo -en "$images\n$BACK" | rofi -dmenu -i -show-icons -theme-str $(build_theme $GRID_ROWS $GRID_COLS $ICON_SIZE) -p "Wallpaper" -theme $Theme)
            if [[ -z "$wallpaper_choice" ]]; then
                return 0
            elif [[ "$wallpaper_choice" = "$BACK" ]]; then
                main_menu
            else
                WALL="$WALLPAPERS_DIR/$wallpaper_choice"
                main_menu
            fi
            ;;
        "Apply")
             if [ -n "$WALL" ]; then
               if [[ "$MODE" = "light" ]]; then
                  PYWAL="wal --cols16 -l -i $WALL"
                  echo "$PYWAL"
                else
                  PYWAL="wal --cols16 -i $WALL"
                  echo "$PYWAL"
                fi
# Apply wallpaper and configuration sequentially
swww img "$WALL" --transition-fps 30 --transition-step 30 & wait
eval $PYWAL & wait
magick "$WALL" -resize 640x360 -quality 10 "$HOME/.config/current_wall.png" & wait
gsettings set org.gnome.desktop.interface color-scheme "prefer-$MODE" & wait
cp -rf "$HOME/.cache/wal/colors-kitty.conf" "$HOME/.config/kitty/colors.conf" & wait
cp -rf "$HOME/.cache/wal/colors-gtk.css" "$HOME/.config/gtk-3.0/colors-gtk.css" & wait
cp -rf "$HOME/.cache/wal/colors-gtk.css" "$HOME/.config/gtk-4.0/colors-gtk.css" & wait
cp -rf "$HOME/.cache/wal/colors-qtct.conf" "$HOME/.config/qt6ct/colors/colors-qtct.conf" & wait
cp -rf "$HOME/.cache/wal/colors-hypr.conf" "$HOME/.config/hypr/colors-hypr.conf" & wait
cp -rf "$HOME/.cache/wal/colors-mako" "$HOME/.config/mako/config" & wait
cp -rf "$HOME/.cache/wal/colors-rofi.rasi" "$HOME/.config/rofi/colors.rasi" & wait
cp -rf "$HOME/.cache/wal/colors-waybar.css" "$HOME/.config/waybar/colors.css" & wait
cp -rf "$HOME/.cache/wal/colors-starship.toml" "$HOME/.config/starship.toml" & wait
exec $HOME/.config/hypr/scripts/folder_color.sh & wait
echo "Pywall END !!!!!" & wait
makoctl reload & wait
hyprctl reload & wait
pkill -USR1 kitty & wait
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
