#!/bin/bash

# Set minimal environment for systemd execution
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

DEVICE="/dev/$1"
MOUNT_POINT="/mnt/vetra/dev"

# Debug logging
logger "USB auto-mount: Script called for device $DEVICE"

# Check if already mounted
if mountpoint -q "$MOUNT_POINT"; then
    logger "USB auto-mount: Mount point $MOUNT_POINT is already in use"
    exit 0
fi

# Wait for device to be ready
sleep 2

# Check if device exists and has a filesystem
if [ -b "$DEVICE" ] && /sbin/blkid "$DEVICE" > /dev/null 2>&1; then
    # Get the base disk (e.g., sda from sda1)
    BASE_DISK=$(echo "$DEVICE" | sed 's/[0-9]*$//')
    
    # Find all partitions on this disk
    PARTITIONS=$(lsblk -nr -o NAME,SIZE "$BASE_DISK" | grep -E "${BASE_DISK##*/}[0-9]+" | awk '{print "/dev/" $1 " " $2}')
    
    # Find the largest partition with a filesystem
    LARGEST_PARTITION=""
    LARGEST_SIZE=0
    
    while read -r PART_LINE; do
        if [ -z "$PART_LINE" ]; then continue; fi
        PART_DEV=$(echo "$PART_LINE" | awk '{print $1}')
        PART_SIZE_STR=$(echo "$PART_LINE" | awk '{print $2}')
        
        # Convert size to bytes for comparison
        if echo "$PART_SIZE_STR" | grep -q "G"; then
            PART_SIZE=$(echo "$PART_SIZE_STR" | sed 's/G//' | awk '{printf "%.0f", $1 * 1024 * 1024 * 1024}')
        elif echo "$PART_SIZE_STR" | grep -q "M"; then
            PART_SIZE=$(echo "$PART_SIZE_STR" | sed 's/M//' | awk '{printf "%.0f", $1 * 1024 * 1024}')
        elif echo "$PART_SIZE_STR" | grep -q "K"; then
            PART_SIZE=$(echo "$PART_SIZE_STR" | sed 's/K//' | awk '{printf "%.0f", $1 * 1024}')
        else
            PART_SIZE=$(echo "$PART_SIZE_STR" | awk '{printf "%.0f", $1}')
        fi
        
        # Check if this partition has a filesystem
        if /sbin/blkid "$PART_DEV" > /dev/null 2>&1; then
            logger "USB auto-mount: Found partition $PART_DEV with size $PART_SIZE_STR ($PART_SIZE bytes)"
            if [ "$PART_SIZE" -gt "$LARGEST_SIZE" ]; then
                LARGEST_SIZE="$PART_SIZE"
                LARGEST_PARTITION="$PART_DEV"
            fi
        fi
    done <<< "$PARTITIONS"
    
    # Only proceed if this is the largest partition
    if [ "$DEVICE" != "$LARGEST_PARTITION" ]; then
        logger "USB auto-mount: $DEVICE is not the largest partition ($LARGEST_PARTITION), skipping"
        exit 0
    fi
    
    logger "USB auto-mount: $DEVICE is the largest partition, proceeding with mount"
    
    # Get filesystem type
    FSTYPE=$(/sbin/blkid -o value -s TYPE "$DEVICE" 2>/dev/null || echo "auto")
    logger "USB auto-mount: Detected filesystem type: $FSTYPE"
    
    # Create mount point if it doesn't exist
    mkdir -p "$MOUNT_POINT"
    
    # Ensure mount point has correct permissions and is empty
    chmod 755 "$MOUNT_POINT"
    chown root:root "$MOUNT_POINT"
    
    # Check if mount point is already in use
    if mountpoint -q "$MOUNT_POINT"; then
        logger "USB auto-mount: Mount point $MOUNT_POINT is already in use"
        exit 1
    fi
    
    # Try to clear any existing content
    rm -rf "$MOUNT_POINT"/*  2>/dev/null || true
    
    # Mount the device using systemd-mount
    if systemd-mount --no-block --collect --options=rw,uid=1000,gid=1000,umask=000 "$DEVICE" "$MOUNT_POINT" 2>&1 | logger; then
        logger "USB auto-mount: Successfully mounted $DEVICE to $MOUNT_POINT"
        
        # Set permissions to ensure web server can access files
        chmod 755 "$MOUNT_POINT"
        chown -R 1000:1000 "$MOUNT_POINT" 2>/dev/null || true
    else
        logger "USB auto-mount: Failed to mount $DEVICE to $MOUNT_POINT"
    fi
else
    logger "USB auto-mount: Device $DEVICE not ready or no filesystem detected"
    if [ -b "$DEVICE" ]; then
        logger "USB auto-mount: Device exists but blkid failed: $(/sbin/blkid "$DEVICE" 2>&1)"
    else
        logger "USB auto-mount: Device $DEVICE does not exist"
    fi
fi
