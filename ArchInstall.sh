#!/bin/bash

#############################################################
# Installation Options
#############################################################
keymap="us"
disk="/dev/sda"
os_packages="base base-devel"
os_name="ArchSys"
locale="en_US.UTF-8"
timezone_region="US"
timezone_city="Pacific"
new_root_password="yes"
mirrorlist_country="all"
mirrorlist_protocol="https"
rank_mirrorlist_by="rate"
repository="stable"
usernames=( "erik" )
sudo_update_users=( "erik" )
request_new_user_password="yes"

#############################################################
# Configure Console
#############################################################
console_mouseSupport="no"
console_mouseType="usb"                   #usb, trackpad, ps2

#############################################################
# Security Setup
#############################################################
install_clamAV="yes"
harden_kernal="yes"
harden_ipStack="yes"
install_firewall="ufw"                  # none, ufw, iptables
install_firejail="yes"

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
  first_partition=1
  second_partition=2
  echo -e "o\nw\n" | fdisk $disk_number
  echo -e "n\np\n1\n\n+100mb\na\n\nn\np\n\n\n\n\nw\n" | fdisk $disk_number
  partprobe $disk_number

  #format partitions
  mkfs.ext4 $disk_number$first_partition
  mkfs.ext4 $disk_number$second_partition

  #mount filesystem
  mount $disk_number$second_partition /mnt
  mkdir /mnt/boot
  mount $disk_number$first_partition /mnt/boot

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
  echo "Named OS..."
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
  sed -i "/\"$locale"/,/Include/"'s/^#//' /etc/locale.gen
  echo "LANG=$locale" > /etc/locale.conf
  locale-gen
  echo "Updated Locale..."
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
  timezone_region=$1
  timezone_city=$2

#Create File
cat <<EOF > /mnt/root/quickScript.sh
  #Set timezone
  ln -s /usr/share/zoneinfo/$timezone_region/$timezone_city /etc/localtime
  hwclock --systohc

  #Clock Synchronization
  timedatectl set-ntp true

  #Output Message
  echo "Updated Timezone..."
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
  echo "Updated Root Password..."
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

echo "Users added..."
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
exit
EOF

#Run File
chmod +x /mnt/root/quickScript.sh
arch-chroot /mnt /root/quickScript.sh
}


# CONFIGURE CONSOLE
#############################################
Configure_Console()
{

  consoleMouseSupport="$1"
  consoleMouseType="$2"
  installPacaur="$3"

cat <<EOF > /mnt/root/quickScript.sh
  #Configure Console
  pacman -S bash-completion --noconfirm

  #Enable Console Mouse Support
  if [ "$consoleMouseSupport" == "yes" ]; then
    echo "In mouse support......."
    #USB Mouse
    if [ "$consoleMouseType" == "usb" ]; then
      echo "In USB......."
      pacman -S gpm xf86-input-synaptics --noconfirm
      GPM_ARGS="-m /dev/input/mice -t imps2"
      systemctl enable gpm.service

    #Trackpad
    elif [ "$consoleMouseType" == "trackpad" ]; then
      pacman -S gpm xf86-input-synaptics --noconfirm
      GPM_ARGS="-m /dev/input/mice -t ps2"
      systemctl enable gpm.service

    #PS2
    elif [ "$consoleMouseType" == "ps2" ]; then
      pacman -S gpm xf86-input-synaptics --noconfirm
      GPM_ARGS="-m /dev/psaux -t ps2"
      systemctl enable gpm.service

    #PS2
    else
      echo "Mouse support was not installed..."
    fi
  fi

  #End Script
  echo "Console Configured..."
  exit
EOF

#Run File
chmod +x /mnt/root/quickScript.sh
arch-chroot /mnt /root/quickScript.sh
}

# CONFIGURE SECURITY
#############################################
Secure_OS()
{
  #Arguments
  clamAV="$1"
  kernel="$2"
  ip="$3"
  firewall="$4"
  firejail="$5"


cat <<EOF > /mnt/root/quickScript.sh
  #Add ClamAV
  if [ "$clamAV" == "yes" ]; then
    pacman -S clamav --noconfirm
    freshclam
    systemctl enable clamd.service
  fi

  #Harden kernel
  if [ "$kernel" == "yes" ]; then
    sed -i '15 s/.*/Storage=none/'           /etc/systemd/coredump.conf
    systemctl deamon-reload

    cp /usr/lib/sysctl.d/50-coredump.conf /etc/sysctl.d
    cp /usr/lib/sysctl.d/50-default.conf /etc/sysctl.d

    touch /etc/sysctl.d/50-dmesg-restrict.conf
    echo "kernel.dmesg_restrict = 1" >> /etc/sysctl.d/50-dmesg-restrict.conf
  fi

  #Harden IP Stack
  if [ "$ip" == "yes" ]; then
    echo "## TCP SYN cookie protection (default)" >> /etc/sysctl.d/51-net.conf
    echo "## helps protect against SYN flood attacks" >> /etc/sysctl.d/51-net.conf
    echo "## only kicks in when net.ipv4.tcp_max_syn_backlog is reached" >> /etc/sysctl.d/51-net.conf
    echo "net.ipv4.tcp_syncookies = 1" >> /etc/sysctl.d/51-net.conf
    echo "" >> /etc/sysctl.d/51-net.conf
    echo "## protect against tcp time-wait assassination hazards" >> /etc/sysctl.d/51-net.conf
    echo "## drop RST packets for sockets in the time-wait state" >> /etc/sysctl.d/51-net.conf
    echo "## (not widely supported outside of linux, but conforms to RFC)" >> /etc/sysctl.d/51-net.conf
    echo "net.ipv4.tcp_rfc1337 = 1" >> /etc/sysctl.d/51-net.conf
    echo "" >> /etc/sysctl.d/51-net.conf
    echo "## sets the kernels reverse path filtering mechanism to value 1 (on)" >> /etc/sysctl.d/51-net.conf
    echo "## will do source validation of the packet's recieved from all the interfaces on the machine" >> /etc/sysctl.d/51-net.conf
    echo "## protects from attackers that are using ip spoofing methods to do harm" >> /etc/sysctl.d/51-net.conf
    echo "net.ipv4.conf.default.rp_filter = 1" >> /etc/sysctl.d/51-net.conf
    echo "net.ipv4.conf.all.rp_filter = 1" >> /etc/sysctl.d/51-net.conf
    echo "net.ipv6.conf.default.rp_filter = 1" >> /etc/sysctl.d/51-net.conf
    echo "net.ipv6.conf.all.rp_filter = 1" >> /etc/sysctl.d/51-net.conf
    echo "" >> /etc/sysctl.d/51-net.conf
    echo "## tcp timestamps" >> /etc/sysctl.d/51-net.conf
    echo "## + protect against wrapping sequence numbers (at gigabit speeds)" >> /etc/sysctl.d/51-net.conf
    echo "## + round trip time calculation implemented in TCP" >> /etc/sysctl.d/51-net.conf
    echo "## - causes extra overhead and allows uptime detection by scanners like nmap" >> /etc/sysctl.d/51-net.conf
    echo "## enable @ gigabit speeds" >> /etc/sysctl.d/51-net.conf
    echo "net.ipv4.tcp_timestamps = 0" >> /etc/sysctl.d/51-net.conf
    echo "" >> /etc/sysctl.d/51-net.conf
    echo "## log martian packets" >> /etc/sysctl.d/51-net.conf
    echo "net.ipv4.conf.default.log_martians = 1" >> /etc/sysctl.d/51-net.conf
    echo "net.ipv4.conf.all.log_martians = 1" >> /etc/sysctl.d/51-net.conf
    echo "" >> /etc/sysctl.d/51-net.conf
    echo "## ignore echo broadcast requests to prevent being part of smurf attacks (default)" >> /etc/sysctl.d/51-net.conf
    echo "net.ipv4.icmp_echo_ignore_broadcasts = 1" >> /etc/sysctl.d/51-net.conf
    echo "" >> /etc/sysctl.d/51-net.conf
    echo "## ignore bogus icmp errors (default)" >> /etc/sysctl.d/51-net.conf
    echo "net.ipv4.icmp_ignore_bogus_error_responses = 1" >> /etc/sysctl.d/51-net.conf
    echo "" >> /etc/sysctl.d/51-net.conf
    echo "## send redirects (not a router, disable it)" >> /etc/sysctl.d/51-net.conf
    echo "net.ipv4.conf.default.send_redirects = 0" >> /etc/sysctl.d/51-net.conf
    echo "net.ipv4.conf.all.send_redirects = 0" >> /etc/sysctl.d/51-net.conf
    echo "" >> /etc/sysctl.d/51-net.conf
    echo "## ICMP routing redirects (only secure)" >> /etc/sysctl.d/51-net.conf
    echo "#net.ipv4.conf.default.secure_redirects = 1 (default)" >> /etc/sysctl.d/51-net.conf
    echo "#net.ipv4.conf.all.secure_redirects = 1 (default)" >> /etc/sysctl.d/51-net.conf
    echo "net.ipv4.conf.default.accept_redirects=0" >> /etc/sysctl.d/51-net.conf
    echo "net.ipv4.conf.all.accept_redirects=0" >> /etc/sysctl.d/51-net.conf
    echo "net.ipv6.conf.default.accept_redirects=0" >> /etc/sysctl.d/51-net.conf
    echo "net.ipv6.conf.all.accept_redirects=0" >> /etc/sysctl.d/51-net.conf
  fi

  #Add Firewall
  if [ "$firewall" == "ufw" ]; then
    pacman -S ufw --noconfirm
    ufw enable
    systemctl enable ufw.service
  elif [ "$firewall" == "iptables" ]; then
    pacman -S iptables --noconfirm
    touch /etc/iptables/iptables.rules
    iptables -F
    iptables -X
    iptables -t nat -F
    iptables -t nat -X
    iptables -t mangle -F
    iptables -t mangle -X
    iptables -t raw -F
    iptables -t raw -X
    iptables -t security -F
    iptables -t security -X
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT
    systemctl enable iptables.service
  else
    echo "No firewall installed..."
  fi

  #Add Firejail
  if [ "$firejail" == "yes" ]; then
    pacman -S firejail --noconfirm
  fi

echo "Security Configured..."
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

#Create File
cat <<EOF > /mnt/root/quickScript.sh
#Install Bootloader
pacman -S grub --noconfirm
grub-install --recheck /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
echo "Installed bootloader..."
rm /mnt/root/quickScript.sh
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

case $response in
    [yY][eE][sS]|[yY])
        timedatectl set-ntp true
        Select_Keymap $keymap
        Manage_Partition $disk
        Install_OS "\${os_packages}"
        OS_Name $os_name
        OS_Locale $locale
        #OS_Timezone $timezone_region $timezone_city
        #Root_Password $new_root_password
        #Create_Users usernames[@] sudo_update_users[@] $request_new_user_password
        #Configure_Pacman $mirrorlist_country $mirrorlist_protocol $rank_mirrorlist_by $repository
        #Configure_Console $console_mouseSupport $console_mouseType
        #Secure_OS $install_clamAV $harden_kernal $harden_ipStack $install_firewall $install_firejail
        #Install_Bootloader
        #Reboot
        ;;
    *)
        echo
        echo "Installation was canceled."
        exit
        ;;
    esac
