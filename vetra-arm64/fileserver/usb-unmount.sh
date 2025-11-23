#!/bin/bash

# Set minimal environment for systemd execution
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

DEVICE="/dev/$1"
MOUNT_POINT="/mnt/vetra/dev"

logger "USB auto-mount: Unmount script called for device $DEVICE"

# Check if mount point is currently mounted
if mountpoint -q "$MOUNT_POINT"; then
    # Try systemd-umount first
    if systemd-umount "$MOUNT_POINT" 2>/dev/null; then
        logger "USB auto-mount: Successfully unmounted $DEVICE from $MOUNT_POINT using systemd-umount"
    # Fallback to regular umount
    elif umount "$MOUNT_POINT" 2>/dev/null; then
        logger "USB auto-mount: Successfully unmounted $DEVICE from $MOUNT_POINT using umount"
    else
        logger "USB auto-mount: Failed to unmount $DEVICE from $MOUNT_POINT"
    fi
else
    logger "USB auto-mount: Mount point $MOUNT_POINT is not mounted"
fi
