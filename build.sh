#!/bin/bash

# Load configuration from .env file
if [ -f .env ]; then
  source .env
fi

if [ -z "$TELEGRAM_BOT_KEY" ]; then
  echo "Error: TELEGRAM_BOT_KEY is missing. Please check your .env file."
  exit 1
fi

# Helper function
send_telegram() {
    local message="$1"
    curl -X POST -H 'Content-Type: application/json' \
        -d "{\"chat_id\": \"-1001067745576\", \"message_thread_id\": \"51909\", \"parse_mode\": \"HTML\", \"disable_web_page_preview\": true, \"text\": \"$message\", \"disable_notification\": true}" \
        https://api.telegram.org/bot$TELEGRAM_BOT_KEY/sendMessage
}

cleanup() {
    if [ -n "$REPO" ] && [ -n "$BRANCH" ]; then
        if [ -n "$COMMIT_URL" ]; then
            # Clone succeeded, we have commit info
            send_telegram "💿 Jahitan harian $TODAY-$TODAY_COUNT [ revisi <a href=\\\"$COMMIT_URL\\\">$COMMIT</a> ] dari $REPO_NAME cabang $BRANCH $RESULT. $FAILURE_REASON $ACTION di http://jahitan.blankonlinux.id/$TODAY-$TODAY_COUNT/"
        else
            # Clone failed, no commit info available
            send_telegram "💿 Jahitan harian $TODAY-$TODAY_COUNT dari $REPO_NAME cabang $BRANCH $RESULT. $FAILURE_REASON "
        fi
    fi
}

## Default messages
RESULT="gagal terbit ❌"
ACTION="Log build dapat disimak"
FAILURE_REASON=""

## Args
REPO=$1
BRANCH=$2
COMMIT=$3
REPO_NAME=$(echo "$REPO" | sed -E 's|.*github.com[:/]([^/]+/[^/.]+)(\.git)?|\1|')

# Optional
ARCH=amd64

START=$(date +%s)

sudo umount $(mount | grep live-build | cut -d ' ' -f 3) || true

# This is for auto update build.sh
if [ ! -n "$4"]; then
    sudo rm -rf ./chroot ./local ./cache ./build ./tmp || true
fi

## Skip further steps if this is a build in local computer
if [ -z "$REPO" ] || [ -z "$BRANCH" ]
then
  sudo lb clean --purge
  sudo lb config --architectures $ARCH
  sudo time lb build | sudo tee -a blankon-live-image-$ARCH.build.log
  exit $?
fi

# Setup trap
trap cleanup EXIT

echo "Processing $REPO $BRANCH $COMMIT ..."

## Assume that this is in prod
JAHITAN_PATH=/home/user/jahitan-harian
TODAY=$(date '+%Y%m%d')

# This is for auto update build.sh
if [ ! -n "$4" ]; then
    TODAY_COUNT=$(ls $JAHITAN_PATH | grep $TODAY | wc -l)
    TODAY_COUNT=$(($TODAY_COUNT + 1))
else
    TODAY_COUNT=$4
fi

TARGET_DIR=$JAHITAN_PATH/$TODAY-$TODAY_COUNT

# This is for auto update build.sh
if [ ! -n "$4" ]; then
    mkdir -p $TARGET_DIR
    sudo mkdir -p tmp || true
    sudo chmod -R a+rw tmp

    ## Preparation
    if ! git clone -b $BRANCH $REPO ./tmp/$TODAY-$TODAY_COUNT 2>&1; then
        FAILURE_REASON="Error: Failed to clone $REPO branch $BRANCH"
        exit 1
    fi
    # Double-check the clone succeeded by verifying .git exists
    if [ ! -d "./tmp/$TODAY-$TODAY_COUNT/" ]; then
        FAILURE_REASON="Error: Clone directory is missing or incomplete"
        exit 1
    fi

    # If a specific commit was passed, switch to it.
    # If not, stay on the latest code from the branch.
    if [ -n "$COMMIT" ]; then
        git -C ./tmp/$TODAY-$TODAY_COUNT checkout $COMMIT
    fi

    if [ -f "./tmp/$TODAY-$TODAY_COUNT/build.sh" ]; then
        mv ./build.sh ./build.sh.old
        cp ./tmp/$TODAY-$TODAY_COUNT/build.sh ./build.sh
        chmod +x ./build.sh
        exec ./build.sh "$REPO" "$BRANCH" "$COMMIT" "$TODAY_COUNT"
    else
        exec ./build.sh "$REPO" "$BRANCH" "$COMMIT" "$TODAY_COUNT"
    fi
fi

COMMIT=$(git -C ./tmp/$TODAY-$TODAY_COUNT rev-parse --short HEAD)
CLEAN_REPO_URL=$(echo "$REPO" | sed 's/\.git$//')
COMMIT_URL="$CLEAN_REPO_URL/commit/$COMMIT"
mkdir -p ./tmp/$TODAY-$TODAY_COUNT
sudo rm -rf config
cp -vR ./tmp/$TODAY-$TODAY_COUNT/config config
sed -i 's/BUILD_NUMBER/'"$TODAY-$TODAY_COUNT"'/g' config/bootloaders/syslinux_common/splash.svg

## Build
sudo lb clean
sudo lb config --architectures $ARCH
rm -f blankon-live-image-$ARCH.build.log
sudo lb build 2>&1 | tee blankon-live-image-$ARCH.build.log

if tail -n 10 blankon-live-image-$ARCH.build.log | grep -q "P: Build completed successfully"; then
  RESULT="telah terbit ✅"
  ACTION="Berkas citra dapat diunduh"
  ## Export to jahitan
  cp -v blankon-live-image-$ARCH.contents $TARGET_DIR/blankon-live-image-$ARCH.contents
  cp -v blankon-live-image-$ARCH.files $TARGET_DIR/blankon-live-image-$ARCH.files
  cp -v blankon-live-image-$ARCH.packages $TARGET_DIR/blankon-live-image-$ARCH.packages
  cp -v blankon-live-image-$ARCH.hybrid.iso $TARGET_DIR/blankon-live-image-$ARCH.hybrid.iso
  zsyncmake -u "http://jahitan.blankonlinux.id/current/blankon-live-image-amd64.hybrid.iso" -o $TARGET_DIR/blankon-live-image-$ARCH.hybrid.iso.zsync $TARGET_DIR/blankon-live-image-$ARCH.hybrid.iso
  sha256sum $TARGET_DIR/blankon-live-image-$ARCH.hybrid.iso > $TARGET_DIR/blankon-live-image-$ARCH.hybrid.iso.sha256sum
  rm -rf $JAHITAN_PATH/current
  #ln -s $TARGET_DIR $JAHITAN_PATH/current
  cp -vR $TARGET_DIR $JAHITAN_PATH/current
  echo "$TODAY-$TODAY_COUNT" > $JAHITAN_PATH/current/current.txt
fi

END=$(date +%s)
DURATION=$((END - START))
TOTAL_DURATION="Done in $(date -d@$DURATION -u +%H:%M:%S)."
echo $TOTAL_DURATION
echo $TOTAL_DURATION >> blankon-live-image-$ARCH.build.log
tail -n 100 blankon-live-image-$ARCH.build.log > $TARGET_DIR/blankon-live-image-$ARCH.tail100.build.log.txt
cp -v blankon-live-image-$ARCH.build.log $TARGET_DIR/blankon-live-image-$ARCH.build.log.txt

## Clean up the mounted entities
sudo umount $(mount | grep live-build | cut -d ' ' -f 3) || true
