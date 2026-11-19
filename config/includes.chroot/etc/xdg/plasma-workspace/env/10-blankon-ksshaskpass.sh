#!/bin/sh
# Set ksshaskpass as the standard SSH askpass utility
export SSH_ASKPASS='/usr/bin/ksshaskpass'
export SSH_ASKPASS_REQUIRE='prefer'

ssh-add < /dev/stdin 2>/dev/null || true
