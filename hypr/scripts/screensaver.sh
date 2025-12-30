#!/bin/bash
# Space wallpaper screensaver - fullscreen slideshow with mpv

WALLPAPER_DIR="$HOME/dotfiles/wallpapers/space"
SLIDE_DURATION=8

case "$1" in
    start)
        # Kill any existing screensaver
        pkill -f "mpv.*title=screensaver" 2>/dev/null

        # Get list of wallpapers
        mapfile -t WALLPAPERS < <(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.webp" \) | shuf)

        if [ ${#WALLPAPERS[@]} -eq 0 ]; then
            echo "No wallpapers found in $WALLPAPER_DIR"
            exit 1
        fi

        # Launch mpv as fullscreen slideshow
        mpv --fullscreen \
            --loop-playlist=inf \
            --image-display-duration=$SLIDE_DURATION \
            --no-audio \
            --no-osc \
            --no-osd-bar \
            --no-input-default-bindings \
            --input-conf=/dev/null \
            --cursor-autohide=always \
            --force-window=immediate \
            --title="screensaver" \
            "${WALLPAPERS[@]}" &

        echo $! > /tmp/screensaver.pid
        ;;

    stop)
        # Kill screensaver
        if [ -f /tmp/screensaver.pid ]; then
            kill $(cat /tmp/screensaver.pid) 2>/dev/null
            rm -f /tmp/screensaver.pid
        fi
        pkill -f "mpv.*title=screensaver" 2>/dev/null
        ;;

    *)
        echo "Usage: $0 {start|stop}"
        exit 1
        ;;
esac
