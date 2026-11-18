#!/usr/bin/env bash

# ~/.config/sway/scripts/launch.sh

# Kill Waybar
pkill -x waybar 2>/dev/null

echo "=== Waybar Launch Script Started ==="

# Read JSON from swaymsg
outputs=$(swaymsg -t get_outputs -r)

# Identify the focused monitor
primary_monitor=$(echo "$outputs" | jq -r '.[] | select(.focused == true and .active == true) | .name')
echo "Focused monitor: $primary_monitor"

if [[ -z "$primary_monitor" ]]; then
    echo "No active monitor found. Script aborted."
    exit 1
fi

# Read the resolution of the focused monitor
width=$(echo "$outputs" | jq -r ".[] | select(.name==\"$primary_monitor\") | .current_mode.width")
height=$(echo "$outputs" | jq -r ".[] | select(.name==\"$primary_monitor\") | .current_mode.height")
echo "Resolution of monitor $primary_monitor: ${width}x${height}"

# Debug: Output 'width' to ensure it was extracted correctly
echo "Extracted width: $width"

# Set scaling and paths for configuration and style
SCALE=1
CONFIG=~/.config/waybar/config.jsonc
STYLE=~/.config/waybar/style.css

if [[ "$width" -eq 3840 ]]; then  # Compare with 3840 for 4K
    echo "Exact 4K resolution detected → Using custom configuration and style"
    pkill -x waybar 2>/dev/null
    CONFIG=$HOME/.config/waybar/config-4k.jsonc  # Custom configuration for 4K
    STYLE=$HOME/.config/waybar/style-4k.css      # Custom style for 4K
    SCALE=2                                      # Scale to 2x
    FONT_SIZE=16
    FOOT_FONT_SIZE=16

    for seat in $(swaymsg -t get_seats | jq -r '.[].name'); do
        swaymsg seat "$seat" xcursor_theme ArcAurora-cursors 28
    done

    sed -i "s/\(^font pango:Noto Sans Mono \)[0-9]\+/\1${FONT_SIZE}/" "$HOME/.config/sway/config"
    sed -i "s/\(^#\?\(font=Noto Sans Mono:size=\)[0-9]\+\)/\2${FOOT_FONT_SIZE}/" "$HOME/.config/foot/foot.ini"

    echo "configuration {
      show-icons: true;
      icon-theme: \"Colloid-Green-Dark\";
      font: \"FiraCode Nerd Font ${FONT_SIZE}\";
    }" > "$HOME/.config/rofi/config.rasi"

    echo '@theme "~/.config/rofi/themes/chameleon-grove-green.rasi"' >> "$HOME/.config/rofi/config.rasi"

    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    gsettings set org.gnome.desktop.interface gtk-theme 'Orchis-Green-Dark'
    gsettings set org.gnome.desktop.interface icon-theme 'Colloid-Green-Dark'
    gsettings set org.gnome.desktop.interface cursor-theme 'ArcAurora-cursors'
    gsettings set org.gnome.desktop.interface font-name 'Sans 16'
    flatpak override --user --reset
    flatpak override --user --filesystem="$HOME/.local/share/.themes"
    flatpak override --user --filesystem="$HOME/.local/share/.icons"
    flatpak override --user --env=GTK_THEME="Orchis-Green-Dark"
    flatpak override --user --env=ICON_THEME="Colloid-Green-Dark"
    flatpak override --user --env=CURSOR_THEME="ArcAurora-cursors"
    flatpak override --user --env=GDK_SCALE="1.5"
    flatpak override --user --env=QT_SCALE_FACTOR="1.5"
    flatpak override --user --env=GDK_DPI_SCALE="1.125"
else
    echo "No 4K display detected → Using default configuration and style"
    pkill -x waybar 2>/dev/null

    for seat in $(swaymsg -t get_seats | jq -r '.[].name'); do
        swaymsg seat "$seat" xcursor_theme ArcAurora-cursors
    done

    echo "configuration {
      show-icons: true;
      icon-theme: \"Colloid-Green-Dark\";
      //font: \"FiraCode Nerd Font ${FONT_SIZE}\";
    }" > "$HOME/.config/rofi/config.rasi"

    echo '@theme "~/.config/rofi/themes/chameleon-grove-green.rasi"' >> "$HOME/.config/rofi/config.rasi"

    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    gsettings set org.gnome.desktop.interface gtk-theme 'Orchis-Green-Dark'
    gsettings set org.gnome.desktop.interface icon-theme 'Colloid-Green-Dark'
    gsettings set org.gnome.desktop.interface cursor-theme 'ArcAurora-cursors'
    flatpak override --user --filesystem="$HOME/.local/share/.themes"
    flatpak override --user --filesystem="$HOME/.local/share/.icons"
    flatpak override --user --env=GTK_THEME="Orchis-Green-Dark"
    flatpak override --user --env=ICON_THEME="Colloid-Green-Dark"
    flatpak override --user --env=CURSOR_THEME="ArcAurora-cursors"
    flatpak override --user --env=GDK_SCALE="1"
    flatpak override --user --env=QT_SCALE_FACTOR="1"
fi

# Start Waybar with dynamically chosen parameters
echo "Waybar is starting for $primary_monitor with SCALE=$SCALE..."
WAYBAR_OUTPUT=$primary_monitor GDK_SCALE=$SCALE QT_SCALE_FACTOR=$SCALE nohup waybar -c "$CONFIG" -s "$STYLE" >/tmp/waybar_debug.log 2>&1 &

echo "=== Waybar started ==="
