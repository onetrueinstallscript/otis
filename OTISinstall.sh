# Set the keyboard layout
loadkeys us

# Update the system clock
timedatectl set-ntp true

# Partition the disks
lsblk
echo ""
echo "Drive to partition:"
read drive
echo "Drivetype (UEFI or BIOS):"
read drivetype

partition() {
if [ $drivetype = UEFI ]; then
	parted $drive mklabel gpt
	parted $drive mkpart ESP fat32 1MiB 513MiB
	parted $drive set 1 boot on
	parted $drive mkpart primary ext4 513MiB 20GiB
	parted $drive mkpart primary linux-swap 20GiB 24GiB
	parted $drive mkpart primary ext4 24GiB 100%
elif [ $drivetype = BIOS ]; then
	parted $drive mklabel msdos
	parted $drive mkpart primary ext4 1MiB 20GiB
	parted $drive set 1 boot on
	parted $drive mkpart primary linux-swap 20GiB 24GiB
	parted $drive mkpart primary ext4 24GiB 100%
else
	echo "Invalid option selected, please try again."
	partition $drive
fi
}

partition $drive
echo "Partitioning finished."

# Format the partitions
format() {
if [ drivetype = UEFI ]; then
	mkfs.vfat -F32 $drive\1
	mkfs.ext4 -F $drive\2
	mkfs.ext4 -F $drive\4
	mkswap $drive\3
	swapon $drive\3
elif [ $drivetype = BIOS ]; then
	mkfs.ext4 -F $drive\1
	mkswap $drive\2
	swapon $drive\2
	mkfs.ext4 -F $drive\3
else
	echo "Invalid option selected, please try again."
	format $drive
fi
}

format $drive
echo "Formatting finished."

# Mount the file systems
mount() {
if [ $drivetype = UEFI ]; then
	mount $drive\2 /mnt
	mkdir /mnt/boot
	mkdir /mnt/home
	mount $drive\1 /mnt/boot
	mount $drive\4 /mnt/home
elif [ $drivetype = BIOS ]; then
	echo "Mounting /dev/sda1 to /mnt"
	mount $drive\1 /mnt
	echo "Creating directory /mnt/home"
	mkdir /mnt/home
	echo "Mounting /dev/sda3 to /mnt/home"
	mount $drive\3 /mnt/home
else
	echo "Invalid option selected, please try again."
	mount $drive
fi
}

mount $drive
echo "Mounting finished."

# Install essential packages
pacstrap -i /mnt base linux linux-firmware

# Fstab
genfstab -U /mnt > /mnt/etc/fstab

# Done
echo "System installation complete, please chroot into the system to continue using:"
echo "arch-chroot /mnt"
