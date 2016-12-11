#!/bin/bash

#Add External Source
source config.sh

#Update system clock
timedatectl set-ntp true

#########################################################################################################
# PARTITION SYSTEM & MOUNT
#########################################################################################################

#wipe and create partitions
echo -e "o\nw\n" | fdisk /dev/sda
echo -e "n\np\n1\n\n+100mb\na\n\nn\np\n\n\n\n\nw\n" | fdisk /dev/sda
partprobe /dev/sda

#format partitions
mkfs.ext4 /dev/sda1
mkfs.ext4 /dev/sda2

#mount filesystem
mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot

echo "Formatting Complete..."

#########################################################################################################
# INSTALL ARCH
#########################################################################################################

#Install OS packages
pacstrap /mnt $OS_packages --noconfirm
genfstab -U /mnt >> /mnt/etc/fstab
echo "Installation Complete..."
