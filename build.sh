#!/bin/bash

TELEGRAM_BOT_KEY=""
## Default messages
RESULT="gagal terbit"
ACTION="Log build dapat disimak"

## Args
REPO=$1
BRANCH=$2
# Optional
COMMIT=$3

START=$(date +%s)

sudo umount $(mount | grep live-build | cut -d ' ' -f 3) || true
sudo rm -rf ./tmp || true

## Skip further steps if this is a build in local computer
if [ -z "$REPO" ] || [ -z "$BRANCH" ]
then
  sudo lb clean --purge
  sudo lb config
  sudo time lb build | sudo tee -a blankon-live-image-amd64.build.log
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
sudo chmod -R a+rw tmp

## Preparation
git clone -b $BRANCH $REPO ./tmp/$TODAY-$TODAY_COUNT
mkdir -p ./tmp/$TODAY-$TODAY_COUNT
sudo rm -rf config
cp -vR ./tmp/$TODAY-$TODAY_COUNT/config config
sed -i 's/BUILD_NUMBER/'"$TODAY-$TODAY_COUNT"'/g' config/bootloaders/syslinux_common/splash.svg

## Build
sudo lb clean
sudo lb config --keyring-packages blankon-archive-keyring --debootstrap-options "--exclude=usrmerge,usr-is-merged --keyring=/usr/share/keyrings/blankon-archive-keyring.gpg"
sudo lb build | tee -a blankon-live-image-amd64.build.log

## Live build does not return accurate exit code. Let's determine it from the log.
BUILD_RESULT=$(tail -n 1 blankon-live-image-amd64.build.log)
if [ "$BUILD_RESULT" == "P: Build completed successfully" ];then
  RESULT="telah terbit"
  ACTION="Berkas citra dapat diunduh"
  ## Export to jahitan
  cp -v blankon-live-image-amd64.contents $TARGET_DIR/blankon-live-image-amd64.contents
  cp -v blankon-live-image-amd64.files $TARGET_DIR/blankon-live-image-amd64.files
  cp -v blankon-live-image-amd64.hybrid.iso.zsync $TARGET_DIR/blankon-live-image-amd64.hybrid.iso.zsync
  cp -v blankon-live-image-amd64.packages $TARGET_DIR/blankon-live-image-amd64.packages
  cp -v blankon-live-image-amd64.hybrid.iso $TARGET_DIR/blankon-live-image-amd64.hybrid.iso
  sha256sum $TARGET_DIR/blankon-live-image-amd64.hybrid.iso > $TARGET_DIR/blankon-live-image-amd64.hybrid.iso.sha256sum
  rm $JAHITAN_PATH/current
  ln -s $TARGET_DIR $JAHITAN_PATH/current
  echo "$TODAY-$TODAY_COUNT" > $JAHITAN_PATH/current/current.txt
fi

END=$(date +%s)
DURATION=$((END - START))
TOTAL_DURATION="Done in $(date -d@$DURATION -u +%H:%M:%S)."
echo $TOTAL_DURATION
echo $TOTAL_DURATION >> blankon-live-image-amd64.build.log
cp -v blankon-live-image-amd64.build.log $TARGET_DIR/blankon-live-image-amd64.build.log.txt

## Clean up the mounted entities
sudo umount $(mount | grep live-build | cut -d ' ' -f 3) || true

curl -X POST -H 'Content-Type: application/json' -d "{\"chat_id\": \"-1001323649228\", \"text\": \"Jahitan harian $TODAY-$TODAY_COUNT dari $REPO cabang $BRANCH $RESULT. $ACTION di https://cdimage.blankonlinux.or.id/blankon/jahitan-harian/$TODAY-$TODAY_COUNT/\", \"disable_notification\": true}" https://api.telegram.org/bot$TELEGRAM_BOT_KEY/sendMessage
