#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPLASH="${ROOT_DIR}/config/bootloaders/syslinux_common/splash.svg"

echo "Switching development configuration to production..."
echo

# Replace arsip-dev with arsip in all files.
grep -rl --exclude-dir=.git 'arsip-dev' "$ROOT_DIR" | while IFS= read -r file; do
    echo "Updating: ${file}"
    sed -i 's/arsip-dev/arsip/g' "$file"
done

# Remove "DEVELOPMENT BUILD" from the production splash screen.
if grep -q 'DEVELOPMENT BUILD' "$SPLASH"; then
    echo "Updating: ${SPLASH}"
    sed -i 's/DEVELOPMENT BUILD//g' "$SPLASH"
else
    echo "No \"DEVELOPMENT BUILD\" string found in ${SPLASH}"
fi

echo
echo "Production switch complete."
echo

# Verify.
if grep -R --exclude-dir=.git -n 'arsip-dev' "$ROOT_DIR"; then
    echo
    echo "WARNING: Some arsip-dev references still remain."
else
    echo "✓ No arsip-dev references remain."
fi

if grep -q 'DEVELOPMENT BUILD' "$SPLASH"; then
    echo "WARNING: \"DEVELOPMENT BUILD\" still exists in splash.svg."
else
    echo "✓ \"DEVELOPMENT BUILD\" removed from splash.svg."
fi
