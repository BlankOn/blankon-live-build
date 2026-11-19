#!/bin/sh
# Ensure Orca screen reader and other accessibility tools work seamlessly
# across XWayland and root apps (like Calamares) in the Wayland session.

if [ -n "$DISPLAY" ] && [ -n "$WAYLAND_DISPLAY" ]; then
    xprop -root -format AT_SPI_BUS 8s -set 'AT_SPI_BUS' "$( busctl call --user org.a11y.Bus /org/a11y/bus org.a11y.Bus GetAddress | sed 's/s "\(.*\)"/\1/' )" 2>/dev/null || true
fi
