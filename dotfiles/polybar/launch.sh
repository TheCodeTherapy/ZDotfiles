#!/usr/bin/env sh

killall -q polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

if type "xrandr"; then
    MON=$(xrandr --query | grep " connected" | grep "primary" | cut -d " " -f 1)
    MONITOR=$MON polybar -c ~/.config/polybar/config.ini main &
else
    echo "could not find xrandr, launching default polybar"
    polybar -c ~/.config/polybar/config.ini main &
fi
