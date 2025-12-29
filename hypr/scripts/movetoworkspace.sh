#!/bin/bash
# Smart move to workspace - uses 1-5 on external, 6-10 on laptop
# Usage: movetoworkspace.sh <1-5>

WS=$1
CURRENT_MONITOR=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name')

# Check if external monitor exists
HAS_EXTERNAL=$(hyprctl monitors -j | jq -e '.[] | select(.name == "DP-1")' > /dev/null 2>&1 && echo "yes" || echo "no")

if [ "$HAS_EXTERNAL" = "yes" ] && [ "$CURRENT_MONITOR" = "eDP-1" ]; then
    # Dual monitor, on laptop - use workspaces 6-10
    hyprctl dispatch movetoworkspace $((WS + 5))
else
    # Single monitor OR on external - use workspaces 1-5
    hyprctl dispatch movetoworkspace $WS
fi
