
#!/bin/sh
# ~/bin/dwmtest.sh

# 0) work around the upstream bug so Xephyr will accept input
unset XDG_SEAT

# 1) HDMI logic on real display
HDMI_OUTPUT=$(xrandr | grep "HDMI" | cut -d" " -f1)
if xrandr --display :0 | grep -q "^$HDMI_OUTPUT connected"; then
    xrandr --display :0 --output "$HDMI_OUTPUT" --auto --primary
fi

# 2) launch under Xephyr, detached
setsid xinit ~/.xinitrc -- /usr/bin/Xephyr :1 \
    -screen 1280x720 -dpi 96 -resizeable -ac >/dev/null 2>&1 &

# 3) wait for the window to appear
sleep 0.5

# 4) grab focus, warp pointer, and “press” Ctrl+Shift inside Xephyr
if command -v xdotool >/dev/null; then
  WID=$(xdotool search --onlyvisible --name "^Xephyr" | head -n1)
  xdotool windowactivate --sync $WID
  xdotool mousemove --window $WID 100 100
  xdotool key --window $WID ctrl+shift
fi

exit 0








































