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

#############################################################
# System Console utilities
#############################################################


#########################################################################################################
# PROCESSING - DO NOT CHANGE ANYTHING BELOW THIS LINE
#########################################################################################################
#User Instructions
echo "Before running program please ensure you have the following:"
echo " * Edit ArchInstall.sh to the way you want it configured"
echo " * Have an functional internet connection"
echo ""
echo "To exit out of install please press CTRL-C"
read -p "Otherwise press enter to continue installation"

#Download Library File
wget https://raw.githubusercontent.com/Eriksh/ArchInstall/develop/ArchInstall_Library.sh && chmod +x ArchInstall_Library.sh
	
#Add External Source
source ./ArchInstall_Library.sh

#Update system clock
timedatectl set-ntp true

#Partition system
Partition_and_Format_Disk

#Install OS
#Install_Arch "\${OS_packages}"

#Configure_Arch
#Configure_Arch $OS_name $locale $timezone_region $timezone_city $request_new_root_password

#Configure_Pacman
#Configure_Pacman "\${mirrorlist_country}" "\${mirrorlist_protocol}" "\${rank_mirrorlist_by}" "\${repository}"

#Install Bootloader
#Bootloader

#Secure OS
#Secure_OS $install_antivirus $install_firewall $install_firejail

#Create Users
#Create_Users $usernames $sudo_update_users $request_new_user_password
