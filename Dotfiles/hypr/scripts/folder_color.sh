#!/bin/bash

# Predefined color map (Tela icon theme)
declare -A COLOR_MAP=( 
  ["black"]="#2E3436"        # Tela icon theme black (dark grey)
  ["blue"]="#5C98D1"         # Tela icon theme blue
  ["brown"]="#B16A38"        # Tela icon theme brown
  ["green"]="#4E9A06"        # Tela icon theme green
  ["grey"]="#888A85"         # Tela icon theme grey (light grey)
  ["nord"]="#5E81AC"         # Tela icon theme nord blue
  ["orange"]="#F77F3E"       # Tela icon theme orange
  ["pink"]="#BE999A"         # Tela icon theme pink
  ["purple"]="#9C6D9D"       # Tela icon theme purple
  ["red"]="#EF5D4C"          # Tela icon theme red
  ["ubuntu"]="#DD4814"       # Ubuntu Orange (updated)
  ["yellow"]="#F9D35C"       # Tela icon theme yellow
)

# Function to convert hex to RGB
hex_to_rgb() {
    local hex="$1"
    r=$((16#${hex:1:2}))
    g=$((16#${hex:3:2}))
    b=$((16#${hex:5:2}))
    echo "$r,$g,$b"
}

# Function to calculate RMS distance between two colors
rms_distance() {
    local r1=$1 g1=$2 b1=$3
    local r2=$4 g2=$5 b2=$6
    local diff_r=$((r1 - r2))
    local diff_g=$((g1 - g2))
    local diff_b=$((b1 - b2))
    local rms=$(( (diff_r * diff_r + diff_g * diff_g + diff_b * diff_b) / 3 ))
    echo "$rms"
}

# Path to the input file
input_file="$HOME/.cache/wal/colors"  # Replace with actual path

# Extract the primary_fixed color from the input file
primary_fixed_hex=$(sed -n '7p' "$input_file")

if [ -z "$primary_fixed_hex" ]; then
    echo "primary-fixed color not found in the input file."
    exit 1
fi

echo "Extracted primary-fixed color: $primary_fixed_hex"

# Convert the primary-fixed color to RGB
primary_fixed_rgb=$(hex_to_rgb "$primary_fixed_hex")
IFS=',' read -r r1 g1 b1 <<< "$primary_fixed_rgb"

# Function to find the closest color by RMS distance
find_closest_color_by_rms() {
    local target_r=$1 target_g=$2 target_b=$3
    local closest_color=""
    local min_rms_distance=9999999  # Start with a very large value

    for color_name in "${!COLOR_MAP[@]}"; do
        local color_hex="${COLOR_MAP[$color_name]}"
        local color_rgb
        color_rgb=$(hex_to_rgb "$color_hex")
        IFS=',' read -r r2 g2 b2 <<< "$color_rgb"

        # Calculate RMS distance between target color and current color
        rms=$(rms_distance "$target_r" "$target_g" "$target_b" "$r2" "$g2" "$b2")

        # Update closest color if this one has a smaller RMS distance
        if [ "$rms" -lt "$min_rms_distance" ]; then
            min_rms_distance=$rms
            closest_color="$color_name"
        fi
    done

    echo "$closest_color"
}

# Find the closest color to primary-fixed based on RMS distance
closest_color=$(find_closest_color_by_rms "$r1" "$g1" "$b1")
echo "The closest color to primary-fixed $primary_fixed_hex is: $closest_color"

# Apply the icon theme based on the closest color
gsettings set org.gnome.desktop.interface icon-theme Tela-"$closest_color"
