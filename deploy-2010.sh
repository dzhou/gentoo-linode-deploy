#!/bin/bash 
# kefei dan zhou (kefei.zhou at gmail)
#
# Linode Gentoo 2010.0 64bit deployment script 
# The default gentoo image on linode is on 2008.0 profile 
# To be able to install any recent package you need to sync and update the 
# system which is quite troublesome
# 
# This script will automate the update process and sort out all the blockers
# Run with root from the same directory with the included configs 
# 

# abort if any command returns non-zero
set -e 

# update portage tree and move to 10.0 profile
emerge --sync 
eselect profile set 1
env-update && source /etc/profile

##udpate locales.gen
cp locale.gen /etc/locale.gen
locale-gen

# copy over portage configs
cp etc/portage/* /etc/portage/

# update timezone 
# this assume Eastern time
rm /etc/localtime
ln -s /usr/share/zoneinfo/US/Eastern /etc/localtime

# Remove some use flags from make.conf 
# Some are required or build will break (-bash-completion)
cp make.conf.0 /etc/make.conf 

# Fix touch bug
mv /bin/touch /bin/oldtouch 
echo '#!/bin/sh' > /bin/touch 
echo 'echo -n >> "$1"' >> /bin/touch 
chmod +x /bin/touch 

# Update GNU toolchain
#emerge gcc-config mpfr binutils libstdc++-v3 gcc glibc

# Full update 
#emerge -DuN world

# Merge in all /etc updates 
echo "-5" | etc-update 

# Optional 
# Recommended packages 
# Admin tools 
emerge sudo syslog-ng chkrootkit eix vixie-cron 

# Networking 
emerge iptraf netcat nmap tcpdump traceroute iptables dhcpcd ntp whois

# Dev tools 
emerge ipython git subversion scipy screen vim unzip links app-text/tree

# Servers/DB
emerge mysql apache lighttpd nginx

# Create eix database
eix-update 

# Make sure eth0+sshd are on at boot
rc-update add net.eth0 boot
rc-update add sshd default

# Completed
echo 'gentoo updated'
echo 'remember to create a new user:'
echo '	useradd -m -G users,wheel user1'
echo '	passwd user1'
