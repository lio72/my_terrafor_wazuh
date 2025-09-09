#!/bin/bash
DEVICE="/dev/xvdf"
MOUNT_POINT="/var/"

if [ -b $DEVICE ]; then
  if ! file -s $DEVICE | grep -q "filesystem"; then
    mkfs -t ext4 $DEVICE
  fi

  mkdir -p $MOUNT_POINT
  mount $DEVICE $MOUNT_POINT

  grep -q "$DEVICE" /etc/fstab || echo "$DEVICE $MOUNT_POINT ext4 defaults,nofail 0 2" >> /etc/fstab
fi