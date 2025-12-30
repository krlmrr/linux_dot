#!/bin/bash
# Space wallpaper screensaver - fullscreen slideshow with mpv

WALLPAPER_DIR="$HOME/dotfiles/wallpapers/space"
SLIDE_DURATION=8
INPUT_CONF="/tmp/screensaver-input.conf"

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

        # Create input config that quits on any key/mouse
        cat > "$INPUT_CONF" << 'EOF'
MBTN_LEFT quit
MBTN_RIGHT quit
MBTN_MID quit
WHEEL_UP quit
WHEEL_DOWN quit
ANY_UNICODE quit
ESC quit
SPACE quit
ENTER quit
TAB quit
BS quit
a quit
b quit
c quit
d quit
e quit
f quit
g quit
h quit
i quit
j quit
k quit
l quit
m quit
n quit
o quit
p quit
q quit
r quit
s quit
t quit
u quit
v quit
w quit
x quit
y quit
z quit
0 quit
1 quit
2 quit
3 quit
4 quit
5 quit
6 quit
7 quit
8 quit
9 quit
UP quit
DOWN quit
LEFT quit
RIGHT quit
EOF

        # Launch mpv as fullscreen slideshow
        mpv --fullscreen \
            --loop-playlist=inf \
            --image-display-duration=$SLIDE_DURATION \
            --no-audio \
            --no-osc \
            --no-osd-bar \
            --cursor-autohide=100 \
            --force-window=immediate \
            --title="screensaver" \
            --input-conf="$INPUT_CONF" \
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
        rm -f "$INPUT_CONF"
        ;;

    *)
        echo "Usage: $0 {start|stop}"
        exit 1
        ;;
esac
