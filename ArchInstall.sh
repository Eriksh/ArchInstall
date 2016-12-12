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
echo "OS_packages=\""$OS_packages"\"" > /mnt/config.sh
echo "OS_name=\""$OS_name"\"" >> /mnt/config.sh
echo "locale=\""$locale"\"" >> /mnt/config.sh
echo "timezone_region=\""$timezone_region"\"" >> /mnt/config.sh
echo "timezone_city=\""$timezone_city"\"" >> /mnt/config.sh
echo "request_new_root_password=\""$request_new_root_password"\"" >> /mnt/config.sh
echo "mirrorlist_country=\""$mirrorlist_country"\"" >> /mnt/config.sh
echo "mirrorlist_protocol=\""$mirrorlist_protocol"\"" >> /mnt/config.sh
echo "rank_mirrorlist_by=\""$rank_mirrorlist_by"\"" >> /mnt/config.sh
echo "repository=\""$repository"\"" >> /mnt/config.sh
echo "install_antivirus=\""$install_antivirus"\"" >> /mnt/config.sh
echo "install_firewall=\""$install_firewall"\"" >> /mnt/config.sh
echo "install_firejail=\""$install_firejail"\"" >> /mnt/config.sh
echo "usernames=("$usernames")" >> /mnt/config.sh
echo "sudo_update_users=("$sudo_update_users")" >> /mnt/config.sh
echo "request_new_user_password=\""$request_new_user_password"\"" >> /mnt/config.sh

chmod +x /mnt/config.sh
echo "Created new config file..."

#############################################################
# Download Installation Files
#############################################################
cd /mnt
wget https://raw.githubusercontent.com/Eriksh/ArchInstall/develop/installOS.sh && chmod +x installOS.sh
wget https://raw.githubusercontent.com/Eriksh/ArchInstall/develop/configOS.sh && chmod +x configOS.sh

#############################################################
# Run Install Script
#############################################################
./installOS.sh

#############################################################
# Run Configuration Script
#############################################################
arch-chroot /mnt /mnt/configOS.sh
