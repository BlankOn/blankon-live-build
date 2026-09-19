#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_PATH="${ROOT_DIR}/$(basename "${BASH_SOURCE[0]}")"
SPLASH="${ROOT_DIR}/config/bootloaders/syslinux_common/splash.svg"

echo "Switching development configuration to production..."
echo

# Replace arsip-dev with arsip in regular files.
find "$ROOT_DIR" \
    -type f \
    -not -path "$ROOT_DIR/.git/*" \
    -not -path "$SCRIPT_PATH" \
    -exec grep -Il 'arsip-dev' {} + |
while IFS= read -r file; do
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

# Verify regular files only.
remaining="$(
    find "$ROOT_DIR" \
        -type f \
        -not -path "$ROOT_DIR/.git/*" \
        -exec grep -Il 'arsip-dev' {} + || true
)"

if [ -n "$remaining" ]; then
    echo "WARNING: Some arsip-dev references still remain:"
    echo "$remaining"
else
    echo "✓ No arsip-dev references remain."
fi

if grep -q 'DEVELOPMENT BUILD' "$SPLASH"; then
    echo "WARNING: \"DEVELOPMENT BUILD\" still exists in splash.svg."
else
    echo "✓ \"DEVELOPMENT BUILD\" removed from splash.svg."
fi
