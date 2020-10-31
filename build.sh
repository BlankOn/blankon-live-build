#!/bin/bash

sudo lb clean --purge
sudo lb config
sudo lb build > live-image-amd64.build.log

JAHITAN_PATH=/mnt/cdimage/images/jahitan-harian
ARCH=amd64
TODAY=$(date '+%Y%m%d')
TODAY_COUNT=$(ls $JAHITAN_PATH | grep $TODAY | wc -l)
TODAY_COUNT=$(($TODAY_COUNT + 1))
TARGET_DIR=$JAHITAN_PATH/$TODAY-$TODAY_COUNT

mkdir -p $TARGET_DIR
cp -v live-image-amd64.build.log $TARGET_DIR/$TODAY-$TODAY_COUNT-live-image-amd64.build.log
cp -v live-image-amd64.contents $TARGET_DIR/$TODAY-$TODAY_COUNT-live-image-amd64.contents
cp -v live-image-amd64.files $TARGET_DIR/$TODAY-$TODAY_COUNT-live-image-amd64.files
cp -v live-image-amd64.hybrid.iso $TARGET_DIR/$TODAY-$TODAY_COUNT-live-image-amd64.hybrid.iso
cp -v live-image-amd64.hybrid.iso.zsync.xz $TARGET_DIR/$TODAY-$TODAY_COUNT-live-image-amd64.hybrid.iso.zsync.xz
cp -v live-image-amd64.packages $TARGET_DIR/$TODAY-$TODAY_COUNT-live-image-amd64.packages
sha256sum $TARGET_DIR/$TODAY-$TODAY_COUNT-live-image-amd64.hybrid.iso > $TARGET_DIR/$TODAY-$TODAY_COUNT-live-image-amd64.hybrid.iso.sha256sum
