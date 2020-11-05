#!/bin/bash

TELEGRAM_BOT_KEY=""
## Custom message
RESULT="telah terbit"
ACTION="Berkas citra dapat diunduh"

## Args
REPO=$1
BRANCH=$2
# Optional
COMMIT=$3

## Skip further steps if this is a build in local computer
if [ -z "$REPO" ] || [ -z "$BRANCH" ]
then
  sudo lb clean --purge
  sudo lb config
  sudo time lb build | sudo tee -a live-image-amd64.build.log
  exit $?
fi

echo "Processing $REPO $BRANCH $COMMIT ..."

## Assume that this is in prod
JAHITAN_PATH=/mnt/cdimage/images/jahitan-harian
ARCH=amd64
TODAY=$(date '+%Y%m%d')
TODAY_COUNT=$(ls $JAHITAN_PATH | grep $TODAY | wc -l)
TODAY_COUNT=$(($TODAY_COUNT + 1))
TARGET_DIR=$JAHITAN_PATH/$TODAY-$TODAY_COUNT

mkdir -p $TARGET_DIR
sudo mkdir -p tmp || true
sudo chmod -vR a+rw tmp

## Preparation
git clone $REPO ./tmp/$TODAY-$TODAY_COUNT
mkdir -p ./tmp/$TODAY-$TODAY_COUNT
pushd ./tmp/$TODAY-$TODAY_COUNT
git checkout $BRANCH

## Build
sudo lb clean --purge
sudo lb config
sudo lb build | tee -a live-image-amd64.build.log

## Live build does not return accurate exit code. Let's determine it from the log.
RETVAL=1
BUILD_RESULT=$(tail -n 1 live-image-amd64.build.log)
if [ "$BUILD_RESULT" == "P: Build completed successfully" ];then
  RESULT="gagal terbit"
  ACTION="Log build dapat disimak"
  RETVAL=0
  ## Export to jahitan
  cp -v live-image-amd64.contents $TARGET_DIR/$TODAY-$TODAY_COUNT-live-image-amd64.contents
  cp -v live-image-amd64.files $TARGET_DIR/$TODAY-$TODAY_COUNT-live-image-amd64.files
  cp -v live-image-amd64.hybrid.iso.zsync $TARGET_DIR/$TODAY-$TODAY_COUNT-live-image-amd64.hybrid.iso.zsync
  cp -v live-image-amd64.packages $TARGET_DIR/$TODAY-$TODAY_COUNT-live-image-amd64.packages
  cp -v live-image-amd64.hybrid.iso $TARGET_DIR/$TODAY-$TODAY_COUNT-live-image-amd64.hybrid.iso
  sha256sum $TARGET_DIR/$TODAY-$TODAY_COUNT-live-image-amd64.hybrid.iso > $TARGET_DIR/$TODAY-$TODAY_COUNT-live-image-amd64.hybrid.iso.sha256sum
fi

cp -v live-image-amd64.build.log $TARGET_DIR/$TODAY-$TODAY_COUNT-live-image-amd64.build.log.txt

popd

## Clean up to save more space
sudo umount $(mount | grep live-build | cut -d ' ' -f 3)
sudo rm -rf ./tmp

curl -X POST -H 'Content-Type: application/json' -d "{\"chat_id\": \"-1001323649228\", \"text\": \"Jahitan harian $TODAY-$TODAY_COUNT $RESULT. $ACTION di https://cdimage.blankonlinux.or.id/blankon/jahitan-harian/$TODAY-$TODAY_COUNT/\", \"disable_notification\": true}" https://api.telegram.org/bot$TELEGRAM_BOT_KEY/sendMessage
