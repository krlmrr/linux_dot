#!/bin/bash
# Dynamic workspace setup based on connected monitors
# - With external: 1-5 on external, 6-10 on laptop
# - Without external: 1-5 on laptop only

WAYBAR_CONFIG="$HOME/dotfiles/waybar/config.jsonc"
WAYBAR_LIVE="$HOME/.config/waybar/config.jsonc"

# Check if external monitor is connected
if hyprctl monitors -j | jq -e '.[] | select(.name == "DP-1")' > /dev/null 2>&1; then
    # Dual monitor setup
    echo "Dual monitor detected"

    # Bind and move workspaces to monitors
    for i in 1 2 3 4 5; do
        hyprctl keyword workspace "$i,monitor:DP-1"
        hyprctl dispatch moveworkspacetomonitor "$i DP-1" 2>/dev/null
    done
    hyprctl keyword workspace "3,monitor:DP-1,default:true"

    for i in 6 7 8 9 10; do
        hyprctl keyword workspace "$i,monitor:eDP-1"
        hyprctl dispatch moveworkspacetomonitor "$i eDP-1" 2>/dev/null
    done
    hyprctl keyword workspace "8,monitor:eDP-1,default:true"

    # Ensure default workspaces exist on each monitor
    hyprctl dispatch workspace 8  # Create workspace 8 on eDP-1
    hyprctl dispatch workspace 3  # Switch back to workspace 3 on DP-1

    # Update waybar config for dual monitor
    cat > "$WAYBAR_LIVE" << 'WAYBAR_EOF'
{
    "layer": "top",
    "position": "top",
    "margin-top": 10,
    "margin-left": 6,
    "margin-right": 6,
    "spacing": 0,

    "modules-left": [
        "hyprland/workspaces",
        "hyprland/window"
    ],

    "modules-center": [
        "clock"
    ],

    "modules-right": [
        "tray",
        "backlight",
        "pulseaudio",
        "bluetooth",
        "network",
        "battery",
        "custom/power"
    ],

    "hyprland/workspaces": {
        "on-click": "activate",
        "on-scroll-up": "hyprctl dispatch workspace r-1",
        "on-scroll-down": "hyprctl dispatch workspace r+1",
        "format": "{name}",
        "all-outputs": false,
        "active-only": false,
        "persistent-workspaces": {
            "DP-1": [1, 2, 3, 4, 5],
            "eDP-1": [6, 7, 8, 9, 10]
        }
    },

    "hyprland/window": {
        "format": "{}",
        "max-length": 40,
        "separate-outputs": true
    },

    "tray": {
        "icon-size": 18,
        "spacing": 10
    },

    "clock": {
        "format": "{:%a %b %d  %I:%M %p}",
        "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>"
    },

    "backlight": {
        "format": "{icon} {percent}%",
        "format-icons": ["", "", "", "", "", "", "", "", ""],
        "tooltip": false
    },

    "pulseaudio": {
        "format": "{icon} {volume}%",
        "format-muted": " muted",
        "format-icons": {
            "default": ["", "", ""]
        },
        "on-click": "pavucontrol"
    },

    "bluetooth": {
        "format": "󰂯",
        "format-connected": "󰂯",
        "format-connected-battery": "󰂯",
        "tooltip-format": "{controller_alias}\t{controller_address}\n\n{num_connections} connected",
        "tooltip-format-connected": "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}",
        "tooltip-format-enumerate-connected": "{device_alias}\t{device_address}",
        "tooltip-format-enumerate-connected-battery": "{device_alias}\t{device_address}\t{device_battery_percentage}%",
        "on-click": "blueman-manager"
    },

    "network": {
        "format-wifi": "󰤨",
        "format-ethernet": "󰂯",
        "format-disconnected": "󰤮",
        "tooltip-format": "{ifname}: {ipaddr}/{cidr}",
        "on-click": "nm-connection-editor"
    },

    "battery": {
        "states": {
            "warning": 30,
            "critical": 15
        },
        "format": "{icon} {capacity}%",
        "format-charging": " {capacity}%",
        "format-plugged": " {capacity}%",
        "format-icons": ["", "", "", "", ""]
    },

    "custom/power": {
        "format": "⏻",
        "tooltip": false,
        "on-click": "~/.config/waybar/power-menu.sh"
    }
}
WAYBAR_EOF

else
    # Single laptop monitor
    echo "Single monitor detected"

    # Move any windows from 6-10 to corresponding 1-5
    for ws in 6 7 8 9 10; do
        target=$((ws - 5))
        hyprctl clients -j | jq -r ".[] | select(.workspace.id == $ws) | .address" | while read -r addr; do
            if [ -n "$addr" ]; then
                hyprctl dispatch movetoworkspace "$target,address:$addr"
            fi
        done
    done

    # Bind and move workspaces 1-5 to laptop
    for i in 1 2 3 4 5; do
        hyprctl keyword workspace "$i,monitor:eDP-1"
        hyprctl dispatch moveworkspacetomonitor "$i eDP-1" 2>/dev/null
    done
    hyprctl keyword workspace "3,monitor:eDP-1,default:true"

    # Switch to workspace 3
    hyprctl dispatch workspace 3

    # Update waybar config for single monitor
    cat > "$WAYBAR_LIVE" << 'WAYBAR_EOF'
{
    "layer": "top",
    "position": "top",
    "margin-top": 10,
    "margin-left": 6,
    "margin-right": 6,
    "spacing": 0,

    "modules-left": [
        "hyprland/workspaces",
        "hyprland/window"
    ],

    "modules-center": [
        "clock"
    ],

    "modules-right": [
        "tray",
        "backlight",
        "pulseaudio",
        "bluetooth",
        "network",
        "battery",
        "custom/power"
    ],

    "hyprland/workspaces": {
        "on-click": "activate",
        "on-scroll-up": "hyprctl dispatch workspace r-1",
        "on-scroll-down": "hyprctl dispatch workspace r+1",
        "format": "{name}",
        "all-outputs": false,
        "active-only": false,
        "persistent-workspaces": {
            "eDP-1": [1, 2, 3, 4, 5]
        }
    },

    "hyprland/window": {
        "format": "{}",
        "max-length": 40,
        "separate-outputs": true
    },

    "tray": {
        "icon-size": 18,
        "spacing": 10
    },

    "clock": {
        "format": "{:%a %b %d  %I:%M %p}",
        "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>"
    },

    "backlight": {
        "format": "{icon} {percent}%",
        "format-icons": ["", "", "", "", "", "", "", "", ""],
        "tooltip": false
    },

    "pulseaudio": {
        "format": "{icon} {volume}%",
        "format-muted": " muted",
        "format-icons": {
            "default": ["", "", ""]
        },
        "on-click": "pavucontrol"
    },

    "bluetooth": {
        "format": "󰂯",
        "format-connected": "󰂯",
        "format-connected-battery": "󰂯",
        "tooltip-format": "{controller_alias}\t{controller_address}\n\n{num_connections} connected",
        "tooltip-format-connected": "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}",
        "tooltip-format-enumerate-connected": "{device_alias}\t{device_address}",
        "tooltip-format-enumerate-connected-battery": "{device_alias}\t{device_address}\t{device_battery_percentage}%",
        "on-click": "blueman-manager"
    },

    "network": {
        "format-wifi": "󰤨",
        "format-ethernet": "󰂯",
        "format-disconnected": "󰤮",
        "tooltip-format": "{ifname}: {ipaddr}/{cidr}",
        "on-click": "nm-connection-editor"
    },

    "battery": {
        "states": {
            "warning": 30,
            "critical": 15
        },
        "format": "{icon} {capacity}%",
        "format-charging": " {capacity}%",
        "format-plugged": " {capacity}%",
        "format-icons": ["", "", "", "", ""]
    },

    "custom/power": {
        "format": "⏻",
        "tooltip": false,
        "on-click": "~/.config/waybar/power-menu.sh"
    }
}
WAYBAR_EOF

fi

# Restart waybar
pkill waybar
sleep 0.3
hyprctl dispatch exec waybar
