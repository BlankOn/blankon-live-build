```bash
#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARCHIVE_CONF="${ROOT_DIR}/config/includes.chroot/etc/blankon/archive.conf"
SPLASH_SVG="${ROOT_DIR}/config/bootloaders/syslinux_common/splash.svg"

echo "Switching development configuration to production..."
echo

if [ ! -w "$ARCHIVE_CONF" ]; then
    echo "Error: ${ARCHIVE_CONF} is missing or not writable."
    exit 1
fi

if [ ! -w "$SPLASH_SVG" ]; then
    echo "Error: ${SPLASH_SVG} is missing or not writable."
    exit 1
fi

# archive.conf is the single source of truth for the archive; build-iso
# rewrites the LB_*MIRROR* entries in config/bootstrap from it on every run,
# so only ARCHIVE_HOST needs switching here.
if grep -q '^ARCHIVE_HOST="arsip-dev\.' "$ARCHIVE_CONF"; then
    echo "Updating: ${ARCHIVE_CONF}"
    sed -i 's/^ARCHIVE_HOST="arsip-dev\./ARCHIVE_HOST="arsip./' "$ARCHIVE_CONF"
else
    echo "No arsip-dev ARCHIVE_HOST found in ${ARCHIVE_CONF}"
fi

# Remove the DAILY_BUILD marker from the production splash screen.
if grep -q 'DAILY_BUILD' "$SPLASH_SVG"; then
    echo "Updating: ${SPLASH_SVG}"
    sed -i 's/DAILY_BUILD//g' "$SPLASH_SVG"
else
    echo "No DAILY_BUILD marker found in ${SPLASH_SVG}"
fi

echo
echo "Production switch complete."
echo

if grep -q '^ARCHIVE_HOST="arsip-dev\.' "$ARCHIVE_CONF"; then
    echo "WARNING: ARCHIVE_HOST still points at arsip-dev."
    exit 1
fi

if grep -q 'DAILY_BUILD' "$SPLASH_SVG"; then
    echo "WARNING: DAILY_BUILD still exists in ${SPLASH_SVG}."
    exit 1
fi

grep '^ARCHIVE_HOST=' "$ARCHIVE_CONF"
echo "✓ ARCHIVE_HOST points at the production archive."
echo "✓ DAILY_BUILD removed from the production splash screen."
```

