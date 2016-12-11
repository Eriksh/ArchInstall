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
################################################################################
# DO NOT TOUCH ANYTHING BELOW THIS LINE
################################################################################
################################################################################

#############################################################
# Create Seperate Config File
#############################################################
echo "OS_packages=\""$OS_packages"\"" >> /mnt/ArchConfig
echo "OS_name=\""$OS_name"\"" >> /mnt/ArchConfig
echo "locale=\""$locale"\"" >> /mnt/ArchConfig
echo "timezone_region=\""$timezone_region"\"" >> /mnt/ArchConfig
echo "timezone_city=\""$timezone_city"\"" >> /mnt/ArchConfig
echo "request_new_root_password=\""$request_new_root_password"\"" >> /mnt/ArchConfig
echo "mirrorlist_country=\""$mirrorlist_country"\"" >> /mnt/ArchConfig
echo "mirrorlist_protocol=\""$mirrorlist_protocol"\"" >> /mnt/ArchConfig
echo "rank_mirrorlist_by=\""$rank_mirrorlist_by"\"" >> /mnt/ArchConfig
echo "repository=\""$repository"\"" >> /mnt/ArchConfig
echo "install_antivirus=\""$install_antivirus"\"" >> /mnt/ArchConfig
echo "install_firewall=\""$install_firewall"\"" >> /mnt/ArchConfig
echo "install_firejail=\""$install_firejail"\"" >> /mnt/ArchConfig
