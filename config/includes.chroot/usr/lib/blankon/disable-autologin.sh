#!/bin/bash
# Remove password so the user can log back in by just clicking
# on the user icon (no password prompt), like Fedora live.
# Only runs in a live session.

grep -q 'boot=live' /proc/cmdline || exit 0

sudo passwd -d blankon
