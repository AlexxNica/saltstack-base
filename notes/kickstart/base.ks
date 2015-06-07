#version=RHEL7

eula --agreed

# the Setup Agent is not started the first time the system boots
firstboot --disable

# text mode (no graphical mode)
text
# do not configure X
skipx
# non-interactive command line mode
cmdline
# install
install

# network
network --bootproto=dhcp --device=enp0s20f0 --noipv6 --onboot=yes --mtu=9000 --activate
##network --bootproto=static --device=enp0s20f1 --noipv6 --onboot=no
##network --bootproto=static --device=enp0s20f2 --noipv6 --onboot=no
##network --bootproto=static --device=enp0s20f3 --noipv6 --onboot=no

# installation path
url --url=http://10.0.0.6/repo/centos/7/os/x86_64
# repository
repo --name="CentOS Base"   --baseurl=http://10.0.0.6/repo/centos/7/os/x86_64
repo --name="CentOS Update" --baseurl=http://10.0.0.6/repo/centos/7/updates/x86_64
repo --name="EPEL"          --baseurl=http://10.0.0.6/repo/centos/7/epel

# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'
# System language
lang en_US.UTF-8
# timezone
timezone --utc UTC

# root password
rootpw --iscrypted $6$kwlYiwH6E7ns4Vre$qNbXf3oFF7YRhv9rLTSK81XHkzc2TmuVKZEZJ1s.UwXklNduDCTi9jUpdRp61ejwnxxn9GVMLcOVfhn6iKakT/
# System authorization information
auth --enableshadow --passalgo=sha512

# SElinux
selinux --disabled
# firewall
firewall --disabled

# bootloader
bootloader --location=mbr --boot-drive=sdb
# clear the MBR (Master Boot Record)
zerombr
clearpart --all --initlabel

# Disk partitioning information
part /boot --fstype="ext4" --ondisk=sdb --size=512 --fsoptions=rw,noatime
part swap --fstype="swap" --ondisk=sdb --size=4096
part / --fstype="ext4" --ondisk=sdb --size=1 --grow --fsoptions=rw,noatime
#part /var --fstype="ext4" --ondisk=sdc --size=1 --grow --fsoptions=rw,noatime

# Reboot
reboot --eject

################################################################################
%packages --nobase --ignoremissing
@core
-aic94xx-firmware*
-alsa-*
-avahi
-ivtv*
-iwl*firmware
-ModemManager*
-NetworkManager*
-wpa_supplicant
salt-minion
%end
################################################################################
%post

KS_URL=http://10.0.0.6

curl $KS_URL/hosts > /etc/hosts
# Based on the IP address returned from the DHCP server, lookup the 
# hostname in /etc/hosts and set it
IP=`ip a show enp0s20f0 | grep 'inet ' | awk '{print $2}' | cut -f1 -d '/'`
HOSTNAME=`grep $IP /etc/hosts | awk '{print $3}'`
echo ${HOSTNAME} > /etc/hostname
hostname ${HOSTNAME}

#for x in `cat /proc/cmdline`; do
#    case $x in HOSTNAME*)
#        eval $x
#        echo ${HOSTNAME} > /etc/hostname
#        hostname ${HOSTNAME}
#        ;;
#    esac
#done

yum -y clean all
yum -y update

hostname -s > /etc/salt/minion_id
systemctl enable salt-minion.service

%end
################################################################################
