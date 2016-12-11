#!/bin/bash

#Add External Source
source config.sh

#########################################################################################################
# CONFIGURE ARCH
#########################################################################################################

#Generate Fstab
genfstab -U /mnt >> /mnt/etc/fstab

#Chroot into new install
arch-chroot /mnt

#Set hostname
echo "$OS_name" > /etc/hostname

#Set locale
sed -i '/' "$locale" '/s/^#//g' /etc/locale.gen
echo "LANG=$locale" > /etc/locale.conf
locale-gen

#Set timezone
ln -s /usr/share/zoneinfo/$timezone_region/$timezone_city /etc/localtime
hwclock --systohc

#Create new root password
if [ "$request_new_root_password" == "yes" ]; then
	clear
	echo "Please enter root password:"
	passwd root
fi

#Get wireless networking packages
pacman -S iw wpa_supplicant dialog --noconfirm

echo "Configuration Complete..."

# #########################################################################################################
# # CONFIGURE PACMAN
# #########################################################################################################
# Configure_Pacman ()
# {
#
# 	#Install both HTTP and HTTPS mirrorlists
# 	if [ "$mirrorlist_protocol" == "all" ]; then
#
# 		if [ "$mirrorlist_country" == "All" ]; then
#
# 			reflector --verbose --protocol http --protocol https --sort $rank_mirrorlist_by --save /etc/pacman.d/mirrorlist
#
# 		else
#
# 			reflector --verbose --country "$mirrorlist_country" --protocol http --protocol https --sort $rank_mirrorlist_by --save /etc/pacman.d/mirrorlist
#
# 		fi
#
# 	else
#
# 		if [ "$mirrorlist_country" == "All" ]; then
#
# 			reflector --verbose --protocol $mirrorlist_protocol --sort $rank_mirrorlist_by --save /etc/pacman.d/mirrorlist
#
# 		else
#
# 			reflector --verbose --country "$mirrorlist_country" --protocol $mirrorlist_protocol --sort $rank_mirrorlist_by --save /etc/pacman.d/mirrorlist
#
# 		fi
#
# 	fi
#
# 	#Select Repository
# 	if [ "$repository" == "stable" ]; then
# 		sed -i "/\[core\]/,/Include/"'s/^#//' /etc/pacman.conf
# 		sed -i "/\[extra\]/,/Include/"'s/^#//' /etc/pacman.conf
# 		sed -i "/\[community\]/,/Include/"'s/^#//' /etc/pacman.conf
# 		sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
# 		sed -i "/\[testing\]/,/Include/"'s/^/#/' /etc/pacman.conf
# 		sed -i "/\[community-testing\]/,/Include/"'s/^/#/' /etc/pacman.conf
# 		sed -i "/\[multilib-testing\]/,/Include/"'s/^/#/' /etc/pacman.conf
#
# 	elif [ "$repository" == "testing" ]; then
# 		sed -i "/\[core]/,/Include/"'s/^/#/' /etc/pacman.conf
# 		sed -i "/\[extra]/,/Include/"'s/^/#/' /etc/pacman.conf
# 		sed -i "/\[community]/,/Include/"'s/^/#/' /etc/pacman.conf
# 		sed -i "/\[multilib]/,/Include/"'s/^/#/' /etc/pacman.conf
# 		sed -i "/\[testing]/,/Include/"'s/^#//' /etc/pacman.conf
# 		sed -i "/\[community-testing]/,/Include/"'s/^#//' /etc/pacman.conf
# 		sed -i "/\[multilib-testing]/,/Include/"'s/^#//' /etc/pacman.conf
#
# 	else
# 		echo "Invalid repository selected: $repository"
# 		exit
#
# 	fi
#
# 	#Refresh and repopulate pacman
# 	pacman-key --init
# 	pacman-key --refresh-key
# 	pacman-key --populate archlinux
# 	pacman -Syy
# 	pacman -Syu --noconfirm
#
# 	echo "Finished configuring pacman"
# }
#
# #########################################################################################################
# # INSTALL BOOTLOADER
# #########################################################################################################
# Bootloader ()
# {
# 	pacman -S grub --noconfirm
# 	grub-install --recheck /dev/sda
# 	grub-mkconfig -o /boot/grub/grub.cfg
#
# 	echo "Finished installing bootloader"
# }
#
# #########################################################################################################
# # SECURITY
# #########################################################################################################
# Secure_OS()
# {
#
# 	#Install Antivirus
# 	if [ $install_antivirus == "yes" ]; then
#
# 		pacman -S clamav --noconfirm
# 		freshclam
# 		systemctl enable clamd.service
# 		systemctl start clamd.service
#
# 	fi
#
# 	#Install Firewall
# 	if [ $install_firewall == "yes" ]; then
#
# 		pacman -S ufw --noconfirm
# 		ufw enable
# 		systemctl enable ufw
# 		systemctl start ufw
#
# 	fi
#
# 	#Install Firejail
# 	if [ $install_firejail == "yes" ]; then
#
# 		pacman -S firejail --noconfirm
#
# 	fi
#
# 	echo "Finished securing OS..."
# }
#
#
#
# #########################################################################################################
# # CREATE USERS
# #########################################################################################################
# echo "Run Ended"
#
#
# Create_Users()
# {
# 	usernames=$1
# 	addToSudo=$2
# 	newUserPass=$4
#
# 	#Download sudo
# 	pacman -S sudo --noconfirm
#
# 	#Create users
# 	for username in $usernames; do
#
# 		#Create user
# 		useradd -m -G wheel -s /bin/bash $username
#
# 		#Create new user password
# 		if [ "$newUserPass" == "yes" ]; then
# 			clear
# 			echo "Please enter password for user $username:"
# 			passwd $username
# 		fi
#
# 	done
#
# 	#Create users
# 	for username in $addToSudo; do
#
# 		#Add user to sudo
# 		if [ "$addToSudo" == "yes" ]; then
#
# 			echo "$username  ALL=(ALL:ALL) ALL" >> /etc/sudoers
#
# 		fi
#
# 	done
#
# 	echo "Finished adding user"
# }
