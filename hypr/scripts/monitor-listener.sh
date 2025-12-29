#!/bin/bash
# Listen for monitor connect/disconnect events and run workspace-setup.sh

SCRIPT_DIR="$(dirname "$0")"
PENDING_FILE="/tmp/monitor-change-pending"

socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
    case $line in
        monitoradded*|monitorremoved*)
            if [ ! -f "$PENDING_FILE" ]; then
                touch "$PENDING_FILE"
                "$SCRIPT_DIR/workspace-setup.sh"
                rm -f "$PENDING_FILE"
            fi
            ;;
    esac
done
