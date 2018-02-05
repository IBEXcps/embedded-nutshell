#!/bin/bash
#
# createArchSDCard: a wrapper script to install Arch on a SD card to be used in a
#               Raspberry Pi
# Author:       Nicholas Fong
#               Patrick José Pereira
#               https://github.com/nickfong/Raspberry-Pi-Archlinux
# Usage:        createSDCard TARGET_DEV 1|2|PATH_TO.TAR.GZ
#
# Update History
# YYYY-MM-DD INITIALS  - DESCRIPTION
# *****************************************************************************
# 2015-12-19 NF        - Create script
# 2015-12-20 NF        - Fix fdisk command to work with spaces
# 2015-12-25 NF        - Check script is run as root, support RPi 1
# 2015-12-27 NF        - Fix argument handling
# 2015-12-30 NF        - Set -euo pipefail
# 2016-01-03 NF        - Add spaces in input director block
# 2016-01-05 NF        - Add header to script
# 2017-03-02 PJP       - Add mmc card support
set -euo pipefail
PROG=$(basename $0)

error() {
    echo -e "ERROR: $*" >&2
    exit 1
}

usage() {
    echo "USAGE: $PROG TARGET_DEV 1|2|PATH_TO.TAR.GZ"
}

if [[ $# -eq 2 ]]; then
    TARGET="$1"
    TARBALL_PATH="$2"
else
    usage && error "Incorrect number of arguments"
fi

# Ensure the target is a sdcard or device
if [[ "$TARGET" =~ ^/dev/sd[a-z]$ ]]; then
    part=""
elif [[ "$TARGET" =~ ^/dev/mmcblk[0-9]$ ]]; then
    part="p"
else
    error "Invalid target: $TARGET"
fi

# Ensure bsdtar is installed
hash bsdtar 2>/dev/null || error "Please install bsdtar"
# Ensure script is being run as root
[[ $EUID -eq 0 ]] || error "This script must be run as root"

echo "You are about to erase $TARGET.  This is what $TARGET looks like according
to fdisk:"
fdisk -l $TARGET
echo
echo "Press return to continue, ^C to cancel"
read -s -n 1 key
if [[ $key != "" ]]; then
    error "Exiting..."
else
    echo
fi

# Run fdisk
echo "Running fdisk on $TARGET"...
sed -e 's/^\s*\([\+0-9a-zA-Z]*\)[ ].*/\1/' << EOF | fdisk $TARGET
    o     #clear partition table
    n     #new partition
    p     #primary partition
    1     #partition 1
          #start at beginning of disk
    +100M #100 MiB boot parttion
    t     #change type
    c     #W95 FAT32 (LBA)
    n     #new partition
    p     #primary partition
    2     #partition number 2
          #accept starting sector
          #accept ending sector
    p     #print partition table
    w     #write partition table
    q     #quit
EOF
echo "Done."
echo

# Create FAT filestystem for /boot
echo "Making FAT filesystem"
mkfs.vfat "$TARGET"${part}1
mkdir boot
mount "$TARGET"${part}1 boot
echo "Done."
echo

# Create ext4 filestystem for /root
echo "Making ext4 filesystem"
mkfs.ext4 "$TARGET"${part}2
mkdir root
mount "$TARGET"${part}2 root
echo "Done."
echo

# Download/locate and un-tar tarball
echo "Finding tarball"
if [[ -a $TARBALL_PATH ]]; then
    echo "Extracting tarball"
    bsdtar -xpf $TARBALL_PATH -C root
elif [[ $TARBALL_PATH -eq 1 ]]; then
    echo "Downloading tarball"
    wget http://archlinuxarm.org/os/ArchLinuxARM-rpi-latest.tar.gz
    echo "Extracting tarball"
    bsdtar -xpf ArchLinuxARM-rpi-latest.tar.gz -C root
elif [[ $TARBALL_PATH -eq 2 ]]; then
    wget http://archlinuxarm.org/os/ArchLinuxARM-rpi-2-latest.tar.gz
    echo "Extracting tarball"
    bsdtar -xpf ArchLinuxARM-rpi-2-latest.tar.gz -C root
else
    echo $TARBALL_PATH
    error "Second argument must be 1, 2, or a valid path to the tarball"
fi
echo "Done.  Syncing..."
sync

# Move files in /root/boot to /boot
echo "Done.  Moving files to boot..."
mv root/boot/* boot
echo "Done.  Unmounting..."
umount boot root
echo "Done."
