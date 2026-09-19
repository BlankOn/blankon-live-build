#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
SPLASH="${ROOT_DIR}/config/bootloaders/syslinux_common/splash.svg"

echo "Switching development configuration to production..."
echo

cd "$ROOT_DIR"

# Replace arsip-dev with arsip in tracked files.
git grep -l 'arsip-dev' -- ':!'"$SCRIPT_NAME" | while IFS= read -r file; do
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

# Verify tracked files only.
if git grep -n 'arsip-dev' -- ':!'"$SCRIPT_NAME"; then
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
