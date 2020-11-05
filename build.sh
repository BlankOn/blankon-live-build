#!/bin/bash

REPO=$1
BRANCH=$2
COMMIT=$3

# Skip further steps if this is a build in local computer
if [ -z "$REPO" ] || [ -z "$BRANCH" ]
then
  sudo lb clean --purge
  sudo lb config
  sudo lb build | sudo tee -a live-image-amd64.build.log
  exit $?
fi

echo "Processing $REPO $BRANCH $COMMIT ..."

# Assume that this is in prod
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
pushd ./tmp/$TODAY-$TODAY_COUNT
git checkout $BRANCH

# Build
sudo lb clean --purge
sudo lb config
sudo lb build | tee -a live-image-amd64.build.log

RETVAL=1
if [ -f $TARGET_DIR/$TODAY-$TODAY_COUNT-live-image-amd64.hybrid.iso];then
  RETVAL=0
fi

## Export to jahitan
sha256sum $TARGET_DIR/$TODAY-$TODAY_COUNT-live-image-amd64.hybrid.iso > $TARGET_DIR/$TODAY-$TODAY_COUNT-live-image-amd64.hybrid.iso.sha256sum
cp -v live-image-amd64.build.log $TARGET_DIR/$TODAY-$TODAY_COUNT-live-image-amd64.build.log.txt
cp -v live-image-amd64.contents $TARGET_DIR/$TODAY-$TODAY_COUNT-live-image-amd64.contents
cp -v live-image-amd64.files $TARGET_DIR/$TODAY-$TODAY_COUNT-live-image-amd64.files
cp -v live-image-amd64.hybrid.iso.zsync $TARGET_DIR/$TODAY-$TODAY_COUNT-live-image-amd64.hybrid.iso.zsync
cp -v live-image-amd64.packages $TARGET_DIR/$TODAY-$TODAY_COUNT-live-image-amd64.packages
cp -v live-image-amd64.hybrid.iso $TARGET_DIR/$TODAY-$TODAY_COUNT-live-image-amd64.hybrid.iso

popd

## Custom message
RESULT="telah terbit"
ACTION="Berkas citra dapat diunduh"
echo $RETVAL
if [ "$RETVAL" -gt "0" ]; then
    RESULT="gagal terbit"
    ACTION="Log-nya dapat disimak"
fi

## Clean up to save more space
sudo rm -rf ./tmp/$TODAY-$TODAY_COUNT

JIN_BOTOL_KEY=""
curl -X POST -H 'Content-Type: application/json' -d "{\"chat_id\": \"-1001323649228\", \"text\": \"Jahitan harian $TODAY-$TODAY_COUNT $RESULT. $ACTION di http://cdimage.blankonlinux.or.id/blankon/jahitan-harian/$TODAY-$TODAY_COUNT/\", \"disable_notification\": true}" https://api.telegram.org/bot$JIN_BOTOL_KEY/sendMessage
