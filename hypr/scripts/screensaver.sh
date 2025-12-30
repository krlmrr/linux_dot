#!/bin/bash
# Space wallpaper screensaver with fade transitions

WALLPAPER_DIR="$HOME/dotfiles/wallpapers/space"
NORMAL_WALLPAPER="$HOME/dotfiles/wallpapers/peakpx.jpg"
FADE_DURATION=2
DISPLAY_TIME=30

# Ensure swww daemon is running
pgrep -x swww-daemon > /dev/null || swww-daemon &
sleep 0.5

case "$1" in
    start)
        # Create marker file
        touch /tmp/screensaver-active

        # Get list of space wallpapers
        wallpapers=($(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.webp" \) 2>/dev/null))

        if [ ${#wallpapers[@]} -eq 0 ]; then
            echo "No wallpapers found in $WALLPAPER_DIR"
            exit 1
        fi

        # Cycle through wallpapers until stopped
        while [ -f /tmp/screensaver-active ]; do
            for wallpaper in "${wallpapers[@]}"; do
                [ ! -f /tmp/screensaver-active ] && break
                swww img "$wallpaper" \
                    --transition-type fade \
                    --transition-duration "$FADE_DURATION" \
                    --transition-fps 60
                sleep "$DISPLAY_TIME"
            done
        done
        ;;

    stop)
        # Remove marker and restore normal wallpaper
        rm -f /tmp/screensaver-active
        sleep 0.5
        swww img "$NORMAL_WALLPAPER" \
            --transition-type fade \
            --transition-duration 1 \
            --transition-fps 60
        ;;

    *)
        echo "Usage: $0 {start|stop}"
        exit 1
        ;;
esac
