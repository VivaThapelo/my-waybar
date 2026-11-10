#!/bin/sh
# Combined CPU / memory / temperature indicator for Waybar.
# Icon follows CPU load; colour class follows the worst of the three.

for z in /sys/class/thermal/thermal_zone*; do
    [ "$(cat "$z/type" 2>/dev/null)" = x86_pkg_temp ] && tz="$z/temp" && break
done
: "${tz:=/sys/class/thermal/thermal_zone0/temp}"

read_cpu() { awk '/^cpu /{print $2+$3+$4+$5+$6+$7+$8+$9, $5+$6; exit}' /proc/stat; }

set -- $(read_cpu); pt=$1; pi=$2
while sleep 3; do
    set -- $(read_cpu); t=$1; i=$2
    dt=$((t - pt)); [ "$dt" -gt 0 ] || dt=1
    cpu=$(( (100 * (dt - (i - pi)) + dt / 2) / dt )); pt=$t; pi=$i

    set -- $(awk '/^MemTotal:/{t=$2} /^MemAvailable:/{a=$2} END{printf "%d %.1f %.1f", (t-a)*100/t, (t-a)/1048576, t/1048576}' /proc/meminfo)
    mem=$1; used=$2; total=$3

    temp=$(( $(cat "$tz" 2>/dev/null || echo 0) / 1000 ))

    if   [ "$cpu" -ge 67 ]; then alt=high
    elif [ "$cpu" -ge 34 ]; then alt=medium
    else alt=low; fi

    if   [ "$cpu" -ge 85 ] || [ "$mem" -ge 90 ] || [ "$temp" -ge 80 ]; then class=critical
    elif [ "$cpu" -ge 60 ] || [ "$mem" -ge 70 ] || [ "$temp" -ge 70 ]; then class=warning
    else class=normal; fi

    printf '{"alt":"%s","class":"%s","tooltip":"CPU   %s%%\\nRAM   %sG / %sG (%s%%)\\nTemp  %s°C"}\n' \
        "$alt" "$class" "$cpu" "$used" "$total" "$mem" "$temp"
done
