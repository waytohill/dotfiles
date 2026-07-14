#!/bin/bash
data=$(cat /tmp/weather_cache | tr -d '\n' | sed \
    -e 's/☀️/SUN/' -e 's/☀/SUN/' \
    -e 's/🌧️/RAIN/' -e 's/🌦️/RAIN/' -e 's/🌨️/SNOW/' \
    -e 's/☁️/CLOUD/' -e 's/🌥️/CLOUD/' -e 's/🌤️/CLOUD/' \
    -e 's/⛈️/STORM/' -e 's/❄️/SNOW/' -e 's/🌫️/FOG/')
temp=$(echo "$data" | grep -oE '[0-9]+' | head -1)

COLOR_HOT="^c#FF79C6^"
COLOR_COLD="^c#8BE9FD^"
COLOR_NICE="^c#F1FA8C^"

if [ -z "$temp" ]; then
    echo "$data"
elif [ "$temp" -le 15 ]; then
    echo "${COLOR_COLD}${data}^d^"
elif [ "$temp" -ge 30 ]; then
    echo "${COLOR_HOT}${data}^d^"
else
    echo "${COLOR_NICE}${data}^d^"
fi
