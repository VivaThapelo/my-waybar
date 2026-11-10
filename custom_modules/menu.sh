#!/bin/sh
# System menu shown under the Arch logo (click the logo, or tap Super).
# Running it again while it is open closes it.

dir=$(dirname "$(readlink -f "$0")")

pkill -f "^wofi --dmenu --prompt sysmenu" && exit 0

choice=$(wofi --dmenu --prompt sysmenu --cache-file /dev/null \
    --style "$dir/menu.css" --location top_left --xoffset 6 --yoffset 6 \
    --width 220 --lines 6 \
    --define hide_search=true --define hide_scroll=true --define no_actions=true \
    --define dynamic_lines=false --define insensitive=true <<EOF
󰀻  Applications…
󰌾  Lock Screen
󰒲  Sleep
󰜉  Restart
󰐥  Shut Down
󰍃  Log Out
EOF
)

case "$choice" in
    *"Applications…") hyprlauncher ;;
    *"Lock Screen") loginctl lock-session ;;
    *"Sleep") systemctl suspend ;;
    *"Restart") systemctl reboot ;;
    *"Shut Down") systemctl poweroff ;;
    *"Log Out") command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()' ;;
esac
