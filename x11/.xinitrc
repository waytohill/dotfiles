#!/bin/sh

setxkbmap us

xset s off
xset -dpms

xrandr --output eDP --mode 2880x1800 --scale 0.666x0.666

xrdb -merge ~/.Xresources

export GTK_IM_MODULE=fcitx5
export QT_IM_MODULE=fcitx5
export XMODIFIERS="@im=fcitx5"
export SDL_IM_MODULE=fcitx5
export GLFW_IM_MODULE=fcitx5


~/.scripts/randomWallpaper.sh &

~/.scripts/autolock.sh &

~/.scripts/updateWeather.sh &

picom --expertimental-backends &

fcitx5 -d &

slstatus &

picom -b &

# xcompmgr &

dispwin -L &



exec dwm

