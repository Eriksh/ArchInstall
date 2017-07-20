#!/bin/bash

#############################################################
# Installation Options
#############################################################
keymap="us"
disk="/dev/sda"
partition_filesystem="uefi"                   #uefi, mbr
swap_partition_size="2G"                      #size[K,M,G]
os_packages="base base-devel"
os_name="ArchSys"
locale="en_US.UTF-8"
timezone_country="US"
timezone_region="Pacific"
timezone_city="America/Los_Angeles"
new_root_password="yes"
mirrorlist_country="all"
mirrorlist_protocol="https"                   #http, https
rank_mirrorlist_by="rate"
repository="stable"                           #stable,
usernames=( "erik" )
sudo_update_users=( "erik" )
request_new_user_password="yes"


#############################################################
# Additional Packages
#############################################################
additional_packages=""

################################################################################
# DO NOT TOUCH ANYTHING BELOW THIS LINE
################################################################################

# KEYMAP
#############################################
Select_Keymap()
{
  select_keymap=$1

  keymap_list=(ANSI-dvorak amiga-de amiga-us applkey atari-de atari-se atari-uk-falcon atari-us azerty backspace bashkir be-latin1 bg-cp1251 bg-cp855 bg_bds-cp1251 bg_bds-utf8 bg_pho-cp1251 bg_pho-utf8 br-abnt br-abnt2 br-latin1-abnt2 br-latin1-us by by-cp1251 bywin-cp1251 cf colemak croat ctrl cz cz-cp1250 cz-lat2 cz-lat2-prog cz-qwertz cz-us-qwertz de de-latin1 de-latin1-nodeadkeys de-mobii de_CH-latin1 de_alt_UTF-8 defkeymap defkeymap_V1.0 dk dk-latin1 dvorak dvorak-ca-fr dvorak-es dvorak-fr dvorak-l dvorak-la dvorak-programmer dvorak-r dvorak-ru dvorak-sv-a1 dvorak-sv-a5 dvorak-uk emacs emacs2 es es-cp850 es-olpc et et-nodeadkeys euro euro1 euro2 fi fr fr-bepo fr-bepo-latin9 fr-latin1 fr-latin9 fr-pc fr_CH fr_CH-latin1 gr gr-pc hu hu101 il il-heb il-phonetic is-latin1 is-latin1-us it it-ibm it2 jp106 kazakh keypad ky_alt_sh-UTF-8 kyrgyz la-latin1 lt lt.baltic lt.l4 lv lv-tilde mac-be mac-de-latin1 mac-de-latin1-nodeadkeys mac-de_CH mac-dk-latin1 mac-dvorak mac-es mac-euro mac-euro2 mac-fi-latin1 mac-fr mac-fr_CH-latin1 mac-it mac-pl mac-pt-latin1 mac-se mac-template mac-uk mac-us mk mk-cp1251 mk-utf mk0 nl nl2 no no-dvorak no-latin1 pc110 pl pl1 pl2 pl3 pl4 pt-latin1 pt-latin9 pt-olpc ro ro_std ro_win ru ru-cp1251 ru-ms ru-yawerty ru1 ru2 ru3 ru4 ru_win ruwin_alt-CP1251 ruwin_alt-KOI8-R ruwin_alt-UTF-8 ruwin_alt_sh-UTF-8 ruwin_cplk-CP1251 ruwin_cplk-KOI8-R ruwin_cplk-UTF-8 ruwin_ct_sh-CP1251 ruwin_ct_sh-KOI8-R ruwin_ct_sh-UTF-8 ruwin_ctrl-CP1251 ruwin_ctrl-KOI8-R ruwin_ctrl-UTF-8 se-fi-ir209 se-fi-lat6 se-ir209 se-lat6 sg sg-latin1 sg-latin1-lk450 sk-prog-qwerty sk-prog-qwertz sk-qwerty sk-qwertz slovene sr-cy sun-pl sun-pl-altgraph sundvorak sunkeymap sunt4-es sunt4-fi-latin1 sunt4-no-latin1 sunt5-cz-us sunt5-de-latin1 sunt5-es sunt5-fi-latin1 sunt5-fr-latin1 sunt5-ru sunt5-uk sunt5-us-cz sunt6-uk sv-latin1 tj_alt-UTF8 tr_f-latin5 tr_q-latin5 tralt trf trf-fgGIod trq ttwin_alt-UTF-8 ttwin_cplk-UTF-8 ttwin_ct_sh-UTF-8 ttwin_ctrl-UTF-8 ua ua-cp1251 ua-utf ua-utf-ws ua-ws uk unicode us us-acentos wangbe wangbe2 windowkeys);
  for KEYMAP in ${keymap_list[*]}; do
      if [ $select_keymap == $KEYMAP ]; then
        loadkeys $select_keymap
        echo "Keymap was set to $select_keymap..."
        break
      fi
  done
}

# PARTITION
#############################################
Manage_Partition()
{
  disk_number=$1
  filesystem=$2
  swap_size=$3
  boot_partition=1
  swap_partition=2
  home_partition=3

  if [ $filesystem == "uefi" ]; then
    echo -e "g\n\nw\n" | fdisk $disk_number
    echo -e "n\n\n\n+256M\n\nt\n1\nw\n" | fdisk $disk_number
    echo -e "n\n\n\n+$swap_size\n\nt\n2\n19\nw\n" | fdisk $disk_number
    echo -e "n\n\n\n\n\nt\n3\n20\nw\n" | fdisk $disk_number
    partprobe $disk_number

    #format partitions
    mkfs.fat -F32 $disk_number$boot_partition
    mkswap $disk_number$swap_partition
    swapon $disk_number$swap_partition
    mkfs.ext4 $disk_number$home_partition

    #mount filesystem
    mount $disk_number$boot_partition /mnt
    mkdir /mnt/boot
    mount $disk_number$first_partition /mnt/boot

    break

  elif [ $filesystem == "mbr" ]; then
    echo -e "o\nw\n" | fdisk $disk_number
    echo -e "n\np\n1\n\n+100mb\na\n\nw\n" | fdisk $disk_number
    echo -e "n\np\n1\n\n+$swap_size\na\n\nw\n" | fdisk $disk_number
    echo -e "n\np\n\n\n\n\nw\n" | fdisk $disk_number
    partprobe $disk_number

    #format partitions
    mkfs.ext4 $disk_number$boot_partition
    mkswap $disk_number$swap_partition
    swapon $disk_number$swap_partition
    mkfs.ext4 $disk_number$home_partition

    #mount filesystem
    mount $disk_number$boot_partition /mnt
    mkdir /mnt/boot
    mount $disk_number$first_partition /mnt/boot

    break

  else
    echo
    echo "Invalid partition type selected"
    echo "Installation was canceled"
    exit
  fi

  echo "Formatting Complete..."
}

# INSTALL
#############################################
Install_OS()
{
  eval OS_packages="$1"

  #Install OS packages
  pacstrap /mnt $OS_packages --noconfirm
  genfstab -U /mnt >> /mnt/etc/fstab
  echo "Installation Complete..."
}

# OS NAME
#############################################
OS_Name()
{
  os_name=$1

#Create File
cat <<EOF > /mnt/root/quickScript.sh
  #Set hostname
  echo "$os_name" > /etc/hostname

#End Script
echo "Named OS..."
rm /root/quickScript.sh
exit
EOF

#Run File
chmod +x /mnt/root/quickScript.sh
arch-chroot /mnt /root/quickScript.sh
}

# OS LOCALE
#############################################
OS_Locale()
{
  locale=$1

#Create File
cat <<EOF > /mnt/root/quickScript.sh
  #Set locale
  sed -i '/$locale/s/^#//g' /etc/locale.gen
  echo "LANG=$locale" > /etc/locale.conf
  locale-gen

#End Script
echo "Updated Locale..."
rm /root/quickScript.sh
exit
EOF

#Run File
chmod +x /mnt/root/quickScript.sh
arch-chroot /mnt /root/quickScript.sh
}

# OS TIMEZONE
#############################################
OS_Timezone()
{
  timezone_region=$1   #changed
  timezone_city=$2     #changed

#Create File
cat <<EOF > /mnt/root/quickScript.sh
  #Set timezone
  ln -s /usr/share/zoneinfo/$timezone_region/$timezone_city /etc/localtime
  hwclock --systohc

  #Clock Synchronization
  timedatectl set-ntp true

#End Script
echo "Updated Timezone..."
rm /root/quickScript.sh
exit
EOF

#Run File
chmod +x /mnt/root/quickScript.sh
arch-chroot /mnt /root/quickScript.sh
}

# NETWORK TIME PROTOCOL
#############################################
Configure_Network_Time_Protocol()
{
  ntp_server_0=$1
  ntp_server_1=$2
  ntp_server_2=$3

#Create File
cat <<EOF > /mnt/root/quickScript.sh
  #Setup NTP
  pacman -S ntp --noconfirm

  #Change NTP Servers
  sed -i "/server 0/c\server $ntp_server_0 iburst" /etc/ntp.conf
  sed -i "/server 1/c\server $ntp_server_1 iburst" /etc/ntp.conf
  sed -i "/server 2/c\server $ntp_server_2 iburst" /etc/ntp.conf
  sed -i "/server 3/c\ " /etc/ntp.conf

  #Start Deamon
  systemctl enable ntpd.service

#End Script
echo "Configured Network Time Protocol..."
rm /root/quickScript.sh
exit
EOF

#Run File
chmod +x /mnt/root/quickScript.sh
arch-chroot /mnt /root/quickScript.sh
}

# NEW ROOT PASSWORD
#############################################
Root_Password()
{
  new_root_password=$1

#Create File
cat <<EOF > /mnt/root/quickScript.sh
  #Create new root password
  if [ "$new_root_password" == "yes" ]; then
    clear
    echo "Please enter root password:"
    for i in {1..5}; do passwd root && break || sleep 1; done
  fi

#End Script
echo "Updated Root Password..."
rm /root/quickScript.sh
exit
EOF

#Run File
chmod +x /mnt/root/quickScript.sh
arch-chroot /mnt /root/quickScript.sh
}

# CREATE USERS
#############################################
Create_Users()
{

cat <<EOF > /mnt/root/quickScript.sh
  # Create Users
  usernames=(${!1})
  addToSudo=(${!2})
  newUserPass=$3

  #Install Sudo
  pacman -S sudo --noconfirm

  #Create users
  for username in \${usernames[*]}; do

  #Create user
  useradd -m -G wheel -s /bin/bash \$username

  #Create new user password
  if [ "\$newUserPass" == "yes" ]; then
    clear
    echo "Please enter password for user \$username:"
    for i in {1..5}; do passwd \$username && break || sleep 1; done
  fi
done

  #Create users
  for username in \${addToSudo[*]}; do

  #Add user to sudo
  echo "\$username  ALL=(ALL:ALL) ALL" >> /etc/sudoers
  done

#End Script
echo "Users Added..."
rm /root/quickScript.sh
exit
EOF

#Run File
chmod +x /mnt/root/quickScript.sh
arch-chroot /mnt /root/quickScript.sh
}

# CONFIGURE PACMAN
#############################################
Configure_Pacman()
{
  #Arguments
	country="$1"
	protocol="$2"
	rank_by="$3"
	repository="$4"

#Create File
cat <<EOF > /mnt/root/quickScript.sh
  #Configure Pacman
  pacman -S reflector --noconfirm

  #Select New Mirrorlist
  if [ "$protocol" == "all" ]; then
    if [ "$country" == "all" ]; then
      reflector --verbose --protocol http --protocol https --sort $rank_by --save /etc/pacman.d/mirrorlist
    else
      reflector --verbose --country "$country" --protocol http --protocol https --sort $rank_by --save /etc/pacman.d/mirrorlist
    fi

  else
    if [ "$country" == "all" ]; then
      reflector --verbose --protocol $protocol --sort $rank_by --save /etc/pacman.d/mirrorlist
    else
      reflector --verbose --country "$country" --protocol $protocol --sort $rank_by --save /etc/pacman.d/mirrorlist
    fi
  fi

  #Select Repository
  if [ "$repository" == "stable" ]; then
    sed -i "/\[core\]/,/Include/"'s/^#//' /etc/pacman.conf
    sed -i "/\[extra\]/,/Include/"'s/^#//' /etc/pacman.conf
    sed -i "/\[community\]/,/Include/"'s/^#//' /etc/pacman.conf
    sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
    sed -i "/\[testing\]/,/Include/"'s/^/#/' /etc/pacman.conf
    sed -i "/\[community-testing\]/,/Include/"'s/^/#/' /etc/pacman.conf
    sed -i "/\[multilib-testing\]/,/Include/"'s/^/#/' /etc/pacman.conf

  elif [ "$repository" == "testing" ]; then
    sed -i "/\[core]/,/Include/"'s/^/#/' /etc/pacman.conf
    sed -i "/\[extra]/,/Include/"'s/^/#/' /etc/pacman.conf
    sed -i "/\[community]/,/Include/"'s/^/#/' /etc/pacman.conf
    sed -i "/\[multilib]/,/Include/"'s/^/#/' /etc/pacman.conf
    sed -i "/\[testing]/,/Include/"'s/^#//' /etc/pacman.conf
    sed -i "/\[community-testing]/,/Include/"'s/^#//' /etc/pacman.conf
    sed -i "/\[multilib-testing]/,/Include/"'s/^#//' /etc/pacman.conf

  else
    echo "Invalid repository selected: $repository"
    exit

  fi

  #Refresh and repopulate pacman
  pacman-key --init
  pacman-key --refresh-key
  pacman-key --populate archlinux
  pacman -Syy
  pacman -Syu --noconfirm
  echo "Configured Pacman..."

#End Script
echo "Pacman Configured..."
rm /root/quickScript.sh
exit
EOF

#Run File
chmod +x /mnt/root/quickScript.sh
arch-chroot /mnt /root/quickScript.sh
}



# INSTALL BOOTLOADER
#############################################
Install_Bootloader()
{
  disk=$1

#Create File
cat <<EOF > /mnt/root/quickScript.sh
  #Install Bootloader
  pacman -S grub --noconfirm
  grub-install --recheck $disk
  grub-mkconfig -o /boot/grub/grub.cfg

#End Script
echo "Installed Bootloader..."
rm /root/quickScript.sh
exit
EOF

#Run File
chmod +x /mnt/root/quickScript.sh
arch-chroot /mnt /root/quickScript.sh
}

# ADDITIONAL PACKAGES
#############################################
Additional_Packages()
{
  packages="$1"

#Create File
cat <<EOF > /mnt/root/quickScript.sh
  #Install Additional Packages
  pacman -S $packages --noconfirm

#End Script
echo "Installing Additional Packages..."
rm /root/quickScript.sh
exit
EOF

#Run File
chmod +x /mnt/root/quickScript.sh
arch-chroot /mnt /root/quickScript.sh
}

# REBOOT
#############################################
Reboot()
{
  clear
  read -rsp $'Installation of the OS has completed.  Please remove the installation media from your PC.
  Press any key to start the system...\n' -n1 key
  umount -R /mnt
  reboot
}

# MAIN
#############################################

clear
read -r -p "You are about to start the installation script.  In order to get a proper Installation
that meets your requirements please do the following:

   * Make sure the PC is currently able to access the internet
   * Modified ArchInstall.sh script to your preference

WARNING: Computer will be ERASED!!!

Are you ready to start the installation (yes/no): " response

case $response in [yY][eE][sS]|[yY])
    timedatectl set-ntp true
    Select_Keymap $keymap
    Manage_Partition $disk $partition_filesystem $swap_partition_size
    #Install_OS "\${os_packages}"
    #OS_Name $os_name
    #OS_Locale $locale
    #OS_Timezone $timezone_region $timezone_city
    #Configure_Network_Time_Protocol $ntp_server_0 $ntp_server_1 $ntp_server_2
    #Root_Password $new_root_password
    #Create_Users usernames[@] sudo_update_users[@] $request_new_user_password
    #Configure_Pacman $mirrorlist_country $mirrorlist_protocol $rank_mirrorlist_by $repository
    #Install_Bootloader $disk
    #Additional_Packages $additional_packages
    #Reboot
    ;;
    *)
    echo
    echo "Installation was canceled."
    exit
    ;;
esac
