#!/bin/bash

# Set the keyboard layout
loadkeys us

# Update the system clock
timedatectl set-ntp true

# Partition the disks
lsblk
echo ""
echo "Drive to partition:"
read drive

parted $drive mklabel gpt
parted $drive mkpart ESP fat32 1MiB 513MiB
parted $drive set 1 boot on
parted $drive mkpart primary ext4 513MiB 20GiB
parted $drive mkpart primary linux-swap 20GiB 24GiB
parted $drive mkpart primary ext4 24GiB 100%

# Format the partitions

mkfs.vfat -F32 $drive\1
mkfs.ext4 -F $drive\2
mkfs.ext4 -F $drive\4
mkswap $drive\3
swapon $drive\3

# Mount the file systems

echo "Mounting to /mnt (UEFI)"
mount $drive\2 /mnt
echo "Creating /boot directory on /mnt"
mkdir /mnt/boot
echo "Creating /home directory on /mnt"
mkdir /mnt/home
echo "Mounting to /mnt/boot"
mount $drive\1 /mnt/boot
echo "Mounting to /mnt/home"
mount $drive\4 /mnt/home

# Install essential packages
pacstrap -i /mnt base linux linux-firmware

# Fstab
genfstab -U /mnt > /mnt/etc/fstab

# Done
echo "System installation complete, please chroot into the system to continue using:"
echo "arch-chroot /mnt"
