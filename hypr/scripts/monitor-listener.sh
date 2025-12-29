#!/bin/bash
# Listen for monitor connect/disconnect events and run workspace-setup.sh

SCRIPT_DIR="$(dirname "$0")"

handle() {
    case $1 in
        monitoradded*|monitorremoved*)
            sleep 1  # Give Hyprland a moment to settle
            "$SCRIPT_DIR/workspace-setup.sh"
            ;;
    esac
}

socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
    handle "$line"
done
