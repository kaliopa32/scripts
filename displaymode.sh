#!/bin/bash

# Resolve internal and external display names
INTERNAL=$(xrandr | grep " connected" | grep -E "eDP|LVDS" | cut -d' ' -f1)
EXTERNAL=$(xrandr | grep " connected" | grep -v "$INTERNAL" | cut -d' ' -f1)

if [[ -z "$INTERNAL" || -z "$EXTERNAL" ]]; then
  echo "Error: Couldn't find both internal and external displays"
  exit 1
fi

MODE="$1"  # optional arg: mirror or extend (defaults to swap on no arg)

applymirror() {		# applys display mirror
  xrandr --output "$EXTERNAL" --off --output "$INTERNAL" --off	
  sleep 0.5
  xrandr --output "$INTERNAL" --mode 1920x1200 --pos 0x0 --primary \
         --output "$EXTERNAL" --mode 1920x1200 --pos 0x0
  echo "Switched to mirror mode"
}

applyextend() {		# applys display extend
  xrandr --output "$EXTERNAL" --off --output "$INTERNAL" --off
  sleep 0.5
  xrandr --output "$INTERNAL" --mode 1920x1200 --pos 0x0 --primary \
         --output "$EXTERNAL" --mode 1920x1200 --pos 1920x0
  echo "Switched to extended mode: $INTERNAL left of $EXTERNAL"
}

case "$MODE" in		# case logic
  mirror)
    applymirror
    ;;
  extend)
    applyextend
    ;;
  *)
    POS=$(xrandr | grep "$EXTERNAL" | grep -oP '\+\d+\+\d+')
    if [[ "$POS" == "+0+0" ]]; then
      applyextend
    else
      applymirror
    fi
    ;;
esac
