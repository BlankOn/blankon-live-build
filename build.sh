#!/bin/bash

sudo lb clean --purge
sudo lb config
sudo lb build | tee -a live-image-amd64.build.log

JAHITAN_PATH=/mnt/cdimage/images/jahitan-harian
ARCH=amd64
TODAY=$(date '+%Y%m%d')
TODAY_COUNT=$(ls $JAHITAN_PATH | grep $TODAY | wc -l)
TODAY_COUNT=$(($TODAY_COUNT + 1))
TARGET_DIR=$JAHITAN_PATH/$TODAY-$TODAY_COUNT

mkdir -p $TARGET_DIR
cp -v live-image-amd64.build.log $TARGET_DIR/$TODAY-$TODAY_COUNT-live-image-amd64.build.log.txt
cp -v live-image-amd64.contents $TARGET_DIR/$TODAY-$TODAY_COUNT-live-image-amd64.contents
cp -v live-image-amd64.files $TARGET_DIR/$TODAY-$TODAY_COUNT-live-image-amd64.files
cp -v live-image-amd64.hybrid.iso $TARGET_DIR/$TODAY-$TODAY_COUNT-live-image-amd64.hybrid.iso
cp -v live-image-amd64.hybrid.iso.zsync $TARGET_DIR/$TODAY-$TODAY_COUNT-live-image-amd64.hybrid.iso.zsync
cp -v live-image-amd64.packages $TARGET_DIR/$TODAY-$TODAY_COUNT-live-image-amd64.packages
sha256sum $TARGET_DIR/$TODAY-$TODAY_COUNT-live-image-amd64.hybrid.iso > $TARGET_DIR/$TODAY-$TODAY_COUNT-live-image-amd64.hybrid.iso.sha256sum

RESULT="telah terbit"
ACTION="Berkas citra dapat diunduh"
retVal=$?
if [ $retVal -ne 0 ]; then
    RESULT="gagal terbit"
    ACTION="Log-nya dapat disimak"
fi

JIN_BOTOL_KEY=""
curl -X POST -H 'Content-Type: application/json' -d "{\"chat_id\": \"-214965156\", \"text\": \"Jahitan harian $TODAY-$TODAY_COUNT $RESULT. $ACTION di http://cdimage.blankonlinux.or.id/blankon/jahitan-harian/$TODAY-$TODAY_COUNT/\", \"disable_notification\": true}" https://api.telegram.org/bot$JIN_BOTOL_KEY/sendMessage
