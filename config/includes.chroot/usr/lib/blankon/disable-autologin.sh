#!/bin/bash
# Disable GDM autologin after the first session.
# This makes the live system behave like Fedora: autologin on first boot,
# then show the login screen after logout.
# Only runs in a live session.

# Exit if not a live session
grep -q 'boot=live' /proc/cmdline || exit 0

GDM_CONF="/etc/gdm3/daemon.conf"

if [ -f "$GDM_CONF" ]; then
    sudo sed -i '/^AutomaticLoginEnable/s/=.*$/=false/' "$GDM_CONF"
fi

# Remove password so the user can log back in by just clicking
# on the user icon (no password prompt), like Fedora live.
sudo passwd -d blankon
