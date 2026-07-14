#!/bin/sh

setxkbmap us

xset s off
xset -dpms

xrandr --output eDP --mode 2880x1800 --scale 0.666x0.666
#xrandr --output eDP --off --output HDMI-A-0 --auto --primary


xrdb -merge ~/.Xresources

export XDG_SESSION_TYPE=x11
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS="@im=fcitx"
export SDL_IM_MODULE=fcitx
export GLFW_IM_MODULE=ibus


~/.scripts/randomWallpaper.sh &

# ~/.scripts/autolock.sh &

~/.scripts/updateWeather.sh &

#picom --expertimental-backends &

fcitx5 -d &

slstatus &

picom -b &

# xcompmgr &

dispwin -L &

# Auto-start clash-verge after dwm is ready (dwm does not support xdg-autostart)
(sleep 3 && /usr/bin/clash-verge) &

# Auto-start Snipaste (screenshot tool, no tray icon support needed)
~/.local/bin/snipaste &

exec dwm

