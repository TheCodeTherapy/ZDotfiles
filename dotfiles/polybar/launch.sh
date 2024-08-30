#!/usr/bin/env sh

## Add this to your wm startup file.

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch bar
if type "xrandr"; then
    for MON in $(xrandr --query | grep " connected" | grep -v "primary" | grep -v "None" | cut -d " " -f 1); do
        MONITOR=$MON polybar -c ~/.config/polybar/config.ini main &
    done
else
    polybar -c ~/.config/polybar/config.ini main &
fi
