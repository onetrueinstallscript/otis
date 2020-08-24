# Set the keyboard layout
loadkeys us

# Update the system clock
timedatectl set-ntp true

# Partition the disks
lsblk
echo ""
echo "Drive to partition:"
read drive

parted $drive mklabel msdos
parted $drive mkpart primary ext4 1MiB 20GiB
parted $drive set 1 boot on
parted $drive mkpart primary linux-swap 20GiB 24GiB
parted $drive mkpart primary ext4 24GiB 100%
echo "Partitioning finished."

# Format the partitions
mkfs.ext4 -F $drive\1
mkswap $drive\2
swapon $drive\2
mkfs.ext4 -F $drive\3

echo "Formatting finished."

# Mount the file systems
echo "Mounting /dev/sda1 to /mnt"
mount $drive\1 /mnt
echo "Creating directory /mnt/home"
mkdir /mnt/home
echo "Mounting /dev/sda3 to /mnt/home"
mount $drive\3 /mnt/home

echo "Mounting finished."

# Install essential packages
pacstrap -i /mnt base linux linux-firmware

# Fstab
genfstab -U /mnt > /mnt/etc/fstab

# Done
echo "System installation complete, please chroot into the system to continue using:"
echo "arch-chroot /mnt"
