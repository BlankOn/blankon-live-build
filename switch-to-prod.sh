#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARCHIVE_CONF="${ROOT_DIR}/config/includes.chroot/etc/blankon/archive.conf"

echo "Switching development configuration to production..."
echo

if [ ! -w "$ARCHIVE_CONF" ]; then
    echo "Error: ${ARCHIVE_CONF} is missing or not writable."
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

echo
echo "Production switch complete."
echo

if grep -q '^ARCHIVE_HOST="arsip-dev\.' "$ARCHIVE_CONF"; then
    echo "WARNING: ARCHIVE_HOST still points at arsip-dev."
    exit 1
fi

grep '^ARCHIVE_HOST=' "$ARCHIVE_CONF"
echo "✓ ARCHIVE_HOST points at the production archive."
