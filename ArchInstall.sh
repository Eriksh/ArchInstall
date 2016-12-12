#!/bin/bash

#############################################################
# Partition and Format Disk
#############################################################

# Partitioning disk is designed for
# to wipe all partitiona and install
# a home & boot partiton. Anyone wishing
# to update this section is welcome

#############################################################
# Install Base OS
#############################################################
OS_packages="base base-devel"

#############################################################
# Configure OS
#############################################################
OS_name="ArchSys"
locale="en_US.UTF-8"
timezone_region="US"
timezone_city="Pacific"
request_new_root_password="yes"

#############################################################
# Configure Pacman
#############################################################
mirrorlist_country="All"			        #(All, United States, etc)
mirrorlist_protocol="https"					#(all, http, https)
rank_mirrorlist_by="rate"					#(rate, score, age, delay, country)
repository="stable"							#(testing, stable)

#############################################################
# Install Bootloader
#############################################################

#This part of the script has been hard
#coded to work with my system, anyone
#wishing to update this section is
#free to do so

#############################################################
# Basic Utilities & Security
#############################################################
install_antivirus="yes"
install_firewall="yes"
install_firejail="yes"

#############################################################
# Creating Users
#############################################################
usernames=(ehall)									#INPUT INFO
sudo_update_users=(ehall)
request_new_user_password="yes"











################################################################################
# DO NOT TOUCH ANYTHING BELOW THIS LINE
################################################################################

#############################################################
# Create Seperate Config File
#############################################################
echo "OS_packages=\""$OS_packages"\"" > /root/config.sh
echo "OS_name=\""$OS_name"\"" >> /root/config.sh
echo "locale=\""$locale"\"" >> /root/config.sh
echo "timezone_region=\""$timezone_region"\"" >> /root/config.sh
echo "timezone_city=\""$timezone_city"\"" >> /root/config.sh
echo "request_new_root_password=\""$request_new_root_password"\"" >> /root/config.sh
echo "mirrorlist_country=\""$mirrorlist_country"\"" >> /root/config.sh
echo "mirrorlist_protocol=\""$mirrorlist_protocol"\"" >> /root/config.sh
echo "rank_mirrorlist_by=\""$rank_mirrorlist_by"\"" >> /root/config.sh
echo "repository=\""$repository"\"" >> /root/config.sh
echo "install_antivirus=\""$install_antivirus"\"" >> /root/config.sh
echo "install_firewall=\""$install_firewall"\"" >> /root/config.sh
echo "install_firejail=\""$install_firejail"\"" >> /root/config.sh
echo "usernames=("$usernames")" >> /root/config.sh
echo "sudo_update_users=("$sudo_update_users")" >> /root/config.sh
echo "request_new_user_password=\""$request_new_user_password"\"" >> /root/config.sh

chmod +x /root/config.sh
echo "Created new config file..."

#############################################################
# Download Installation Files
#############################################################
wget https://raw.githubusercontent.com/Eriksh/ArchInstall/develop/installOS.sh && chmod +x installOS.sh
wget https://raw.githubusercontent.com/Eriksh/ArchInstall/develop/configOS.sh && chmod +x configOS.sh

#############################################################
# Run Install Script
#############################################################
./installOS.sh

#############################################################
# Run Configuration Script
#############################################################
cp configOS.sh /mnt/config.sh
cp configOS.sh /mnt/configOS.sh
genfstab -p -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt ./configOS.sh
