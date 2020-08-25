#!/bin/sh

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
installBootloader() {
if [ $drivetype = "UEFI" ]; then
	touch /boot/loader/entries/arch.conf
	pacman -S dosfstools --noconfirm
	bootctl --path=/boot install
	mkdir -p /boot/loader/entries/
	echo "title	Arch Linux
	linux	/vmlinuz-linux
	initrd	/initramfs-linux.img
	options	root=$drive\2 rw" > /mnt/boot/loader/entries/arch.conf
	
	elif [ $drivetype = "BIOS" ]; then
		mkdir -p /boot/grub/
		pacman -S grub os-prober --noconfirm
		grub-install --recheck /dev/sda
		grub-mkconfig -o /boot/grub/grub.cfg
		
	else
		echo "Invalid option selected, please try again."
		installBootloader
fi
}

installBootloader

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
