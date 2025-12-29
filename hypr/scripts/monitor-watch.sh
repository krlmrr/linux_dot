#!/bin/bash
# Poll for monitor changes and run workspace-setup.sh when detected

SCRIPT_DIR="$(dirname "$0")"
LAST_STATE=""

while true; do
    CURRENT_STATE=$(hyprctl monitors -j | jq -r '[.[].name] | sort | join(",")')

    if [ "$CURRENT_STATE" != "$LAST_STATE" ] && [ -n "$LAST_STATE" ]; then
        sleep 1
        "$SCRIPT_DIR/workspace-setup.sh"
    fi

    LAST_STATE="$CURRENT_STATE"
    sleep 2
done
