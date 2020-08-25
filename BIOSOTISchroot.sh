#!/bin/bash

# Set the time zone
ln -sf /usr/share/zoneinfo/America/Kentucky/Louisville /etc/localtime
hwclock --systohc --utc

# Localization
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen

# Configure hostname
echo "Choose a hostname:"
read hostname
echo $hostname > /etc/hostname
echo "#<ip-address>	<hostname.domain.org>	<hostname>
127.0.0.1		localhost.localdomain	localhost	$hostname
::1		localhost.localdomain	localhost	$hostname" > /etc/hosts

# Install and configure bootloader

mkdir -p /boot/grub/
pacman -S grub os-prober --noconfirm
grub-install --recheck /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

# Create user account
echo "Enter user account name (lowercase, no spaces):"
read username
useradd -m -G wheel -s /bin/bash $username
echo "Enter user account password for $username:"
passwd $username

# Set root password
echo "Enter a password for root:"
passwd

# End installation and reboot
reboot
