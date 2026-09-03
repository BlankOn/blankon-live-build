#!/usr/bin/env bash

set -euo pipefail

# ============================================================
# check-packages-availability.sh
#
# Check package lists against a Debian repository.
#
# Usage:
#
#   ./check-packages-availability.sh \
#       ./config/package-lists/* \
#       https://kartolo.sby.datautama.net.id/debian/ \
#       trixie
#
# The LAST argument is the suite.
# The SECOND-LAST argument is the repository URL.
# Everything before that is treated as a package-list file.
#
# Exit codes:
#   0 = all packages available
#   1 = script/repository error
#   2 = packages missing
# ============================================================

if [[ $# -lt 3 ]]; then
    echo "Usage:"
    echo
    echo "  $0 <package-list-files...> <repo-url> <suite>"
    echo
    echo "Example:"
    echo "  $0 ./config/package-lists/* \\"
    echo "      https://kartolo.sby.datautama.net.id/debian/ \\"
    echo "      trixie"
    exit 1
fi

# ============================================================
# Arguments
# ============================================================

SUITE="${!#}"

REPO_ARG_INDEX=$(($# - 1))
REPO_URL="${!REPO_ARG_INDEX}"
REPO_URL="${REPO_URL%/}"

PACKAGE_FILE_COUNT=$(($# - 2))
PACKAGE_FILES=("${@:1:$PACKAGE_FILE_COUNT}")

ARCH="${ARCH:-$(dpkg --print-architecture 2>/dev/null || echo amd64)}"

# ============================================================
# Temporary files
# ============================================================

TMPDIR="$(mktemp -d)"

cleanup()
{
    rm -rf "$TMPDIR"
}

trap cleanup EXIT

PACKAGE_LIST="$TMPDIR/packages.list"
PACKAGE_NAMES="$TMPDIR/package-names.list"
AVAILABLE_PACKAGES="$TMPDIR/available.list"
RELEASE_FILE="$TMPDIR/Release"

touch "$PACKAGE_LIST"
touch "$AVAILABLE_PACKAGES"

# ============================================================
# Header
# ============================================================

echo "========================================"
echo "Package availability"
echo "========================================"
echo "Repository   : $REPO_URL"
echo "Suite        : $SUITE"
echo "Architecture : $ARCH"
echo

# ============================================================
# Read package lists
#
# Keep source information:
#
#   package<TAB>source-file:line
#
# This makes it possible to find malformed entries.
# ============================================================

echo "Reading package lists..."
echo

for file in "${PACKAGE_FILES[@]}"; do

    if [[ ! -f "$file" ]]; then
        echo "WARNING: Not a file, skipping:"
        echo "  $file"
        echo
        continue
    fi

    echo "  $file"

    line_number=0

    while IFS= read -r line || [[ -n "$line" ]]; do
        line_number=$((line_number + 1))

        # Remove comments.
        line="${line%%#*}"

        # Trim whitespace.
        line="$(sed 's/^[[:space:]]*//;s/[[:space:]]*$//' <<< "$line")"

        # Ignore empty lines.
        [[ -z "$line" ]] && continue

        # Package lists should contain ONE package per line.
        #
        # Do not aggressively split the line here.
        # A malformed concatenated package name should be
        # detected later rather than silently hidden.
        package="$line"

        # Remove architecture qualifier if present.
        package="$(sed -E \
            's/:(amd64|arm64|armhf|armel|i386|ppc64el|riscv64|s390x|all)$//' \
            <<< "$package")"

        printf '%s\t%s:%s\n' \
            "$package" \
            "$file" \
            "$line_number" \
            >> "$PACKAGE_LIST"

    done < "$file"

done

echo

# Extract package names.
cut -f1 "$PACKAGE_LIST" |
    sort -u > "$PACKAGE_NAMES"

PACKAGE_COUNT="$(wc -l < "$PACKAGE_NAMES")"

echo "Packages to check: $PACKAGE_COUNT"
echo

if [[ "$PACKAGE_COUNT" -eq 0 ]]; then
    echo "ERROR: No packages found."
    exit 1
fi

# ============================================================
# Download Release file
# ============================================================

RELEASE_URL="${REPO_URL}/dists/${SUITE}/Release"

echo "Fetching Release:"
echo "  $RELEASE_URL"

if ! curl -fLsS "$RELEASE_URL" -o "$RELEASE_FILE"; then
    echo
    echo "ERROR: Failed to download Release file."
    exit 1
fi

echo "  OK"
echo

# ============================================================
# Get components
# ============================================================

COMPONENTS="$(
    awk '
        /^Components:/ {
            for (i = 2; i <= NF; i++)
                print $i
        }
    ' "$RELEASE_FILE"
)"

if [[ -z "$COMPONENTS" ]]; then
    echo "ERROR: No Components found in Release file."
    exit 1
fi

echo "Components:"
while read -r component; do
    echo "  $component"
done <<< "$COMPONENTS"

echo

# ============================================================
# Download Packages index
# ============================================================

download_packages_index()
{
    local component="$1"
    local architecture="$2"

    local base_url
    local output

    base_url="${REPO_URL}/dists/${SUITE}/${component}/binary-${architecture}"
    output="$TMPDIR/Packages-${component}-${architecture}"

    echo "  Checking ${component}/binary-${architecture}..."

    # --------------------------------------------------------
    # Packages
    # --------------------------------------------------------

    if curl -fLsS \
        "${base_url}/Packages" \
        -o "$output" 2>/dev/null
    then
        echo "    Found Packages"

        awk '
            /^Package:/ {
                print $2
            }
        ' "$output" >> "$AVAILABLE_PACKAGES"

        return 0
    fi

    # --------------------------------------------------------
    # Packages.gz
    # --------------------------------------------------------

    if curl -fLsS \
        "${base_url}/Packages.gz" 2>/dev/null |
        gzip -dc > "$output" 2>/dev/null
    then
        echo "    Found Packages.gz"

        awk '
            /^Package:/ {
                print $2
            }
        ' "$output" >> "$AVAILABLE_PACKAGES"

        return 0
    fi

    # --------------------------------------------------------
    # Packages.xz
    # --------------------------------------------------------

    if curl -fLsS \
        "${base_url}/Packages.xz" 2>/dev/null |
        xz -dc > "$output" 2>/dev/null
    then
        echo "    Found Packages.xz"

        awk '
            /^Package:/ {
                print $2
            }
        ' "$output" >> "$AVAILABLE_PACKAGES"

        return 0
    fi

    echo "    Not found"

    return 1
}

# ============================================================
# Fetch indexes
# ============================================================

echo "Fetching package indexes:"
echo

INDEX_COUNT=0

while read -r component; do

    if download_packages_index "$component" "$ARCH"; then
        INDEX_COUNT=$((INDEX_COUNT + 1))
    fi

    # Architecture-independent packages.
    if [[ "$ARCH" != "all" ]]; then
        if download_packages_index "$component" "all"; then
            INDEX_COUNT=$((INDEX_COUNT + 1))
        fi
    fi

done <<< "$COMPONENTS"

echo

if [[ "$INDEX_COUNT" -eq 0 ]]; then
    echo "ERROR: No Packages indexes could be downloaded."
    exit 1
fi

sort -u "$AVAILABLE_PACKAGES" -o "$AVAILABLE_PACKAGES"

# ============================================================
# Compare
# ============================================================

AVAILABLE="$TMPDIR/available-requested.list"
MISSING="$TMPDIR/missing.list"

comm -12 \
    "$PACKAGE_NAMES" \
    "$AVAILABLE_PACKAGES" \
    > "$AVAILABLE"

comm -23 \
    "$PACKAGE_NAMES" \
    "$AVAILABLE_PACKAGES" \
    > "$MISSING"

AVAILABLE_COUNT="$(wc -l < "$AVAILABLE")"
MISSING_COUNT="$(wc -l < "$MISSING")"

# ============================================================
# Result
# ============================================================

echo "========================================"
echo "Package availability"
echo "========================================"
echo "Repository   : $REPO_URL"
echo "Suite        : $SUITE"
echo "Architecture : $ARCH"
echo
echo "Requested    : $PACKAGE_COUNT"
echo "Available    : $AVAILABLE_COUNT"
echo "Missing      : $MISSING_COUNT"
echo

# ============================================================
# Available
# ============================================================

if [[ "$AVAILABLE_COUNT" -gt 0 ]]; then
    echo "Available packages:"
    echo

    while read -r package; do
        echo "  ✓ $package"
    done < "$AVAILABLE"

    echo
fi

# ============================================================
# Missing
# ============================================================

if [[ "$MISSING_COUNT" -eq 0 ]]; then
    echo "All packages are available."
    exit 0
fi

echo "Missing packages:"
echo

while read -r package; do

    # Find source.
    source="$(
        awk -F '\t' -v pkg="$package" '
            $1 == pkg {
                print $2
                exit
            }
        ' "$PACKAGE_LIST"
    )"

    echo "  ✗ $package"
    echo "      source: $source"

done < "$MISSING"

echo

# ============================================================
# Detect possible concatenated package names
#
# Example:
#
#   systemd-zram-generatorvim
#
# If both:
#
#   systemd-zram-generator
#   vim
#
# exist in the repository, report the suspicious entry.
# ============================================================

echo "Checking for possible concatenated package names..."
echo

FOUND_CONCATENATION=0

while read -r package; do

    # Package names are normally made of:
    #   a-z 0-9 + . - +
    #
    # Try every possible split point.
    length=${#package}

    for ((i=1; i<length; i++)); do

        left="${package:0:i}"
        right="${package:i}"

        # Avoid very short fragments.
        [[ ${#left} -lt 2 ]] && continue
        [[ ${#right} -lt 2 ]] && continue

        left_found=0
        right_found=0

        if grep -Fxq "$left" "$AVAILABLE_PACKAGES"; then
            left_found=1
        fi

        if grep -Fxq "$right" "$AVAILABLE_PACKAGES"; then
            right_found=1
        fi

        if [[ "$left_found" -eq 1 && "$right_found" -eq 1 ]]; then

            if [[ "$FOUND_CONCATENATION" -eq 0 ]]; then
                echo "Possible concatenated package names:"
                echo
            fi

            echo "  ! $package"
            echo "      could be:"
            echo "        - $left"
            echo "        - $right"
            echo

            FOUND_CONCATENATION=1

            # One useful split is enough.
            break
        fi

    done

done < "$MISSING"

if [[ "$FOUND_CONCATENATION" -eq 0 ]]; then
    echo "No obvious concatenated package names detected."
    echo
fi

echo "========================================"

exit 2
