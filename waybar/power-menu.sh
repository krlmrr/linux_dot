#!/bin/bash

choice=$(echo -e "Logout\nRestart\nShutdown\nCancel" | rofi -dmenu -p "Power" -theme-str 'window {width: 200px;}')

case "$choice" in
    Logout)
        hyprctl dispatch exit
        ;;
    Restart)
        systemctl reboot
        ;;
    Shutdown)
        systemctl poweroff
        ;;
    *)
        exit 0
        ;;
esac
