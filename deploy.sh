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


# update portage tree and move to 10.0 profile
emerge --sync 
eselect profile set 1
env-update && source /etc/profile

##udpate locales.gen
cp locales.gen /etc/locales.gen
locales-gen

# update timezone 
# this assume Eastern time
rm /etc/localtime
ln -s /usr/share/zoneinfo/US/Eastern /etc/localtime

# Remove some use flags from make.conf 
# Some are required or build will break (-bash-completion)
cp make.conf.0 /etc/make.conf 

# Resolve blocking portage and python
# Manually upgrade to python26 (include dependencies)
# Alternatively, you can move to python3
emerge -C app-admin/eselect-news
emerge -1 dev-libs/libffi virtual/libffi app-misc/mime-types
emerge -1 sys-devel/automake-wrapper sys-devel/automake sys-devel/libtool 
emerge -1 app-admin/eselect app-admin/eselect-python
emerge --nodeps python 
python-updater

# Update portage (need to use python25)
eselect python set 2 
emerge -C app-arch/lzma-utils && emerge -1 app-arch/xz-utils
emerge portage 
eselect python set 3 

# Update GNU toolchain: gcc-4.1 to gcc-4.4 
# Need to emerge new glibc with gcc-4.4 
emerge gcc-config mpfr binutils libstdc++-v3 gcc
gcc-config 2
source /etc/profile
emerge glibc 

# The right way is to rebuild the toolchain with itself
# (but you can skip this step to shorten the install process)
#emerge gcc-config mpfr binutils libstdc++-v3 gcc glibc 

# Resolve blocking wiht ss/com_err/e2fsprogs/e2fsprogs-libs
emerge -f e2fsprogs e2fsprogs-libs 
emerge -C ss com_err e2fsprogs 
emerge e2fsprogs 

# Resolve blocking with libtool-2.2.8 and libtool-2.2.8
emerge -C libtool 
emerge -1 libtool 

# Remove blocker man-pages-3 
# This is only manpages, will not break anything 
# we'll let full world update take care of reinstall this 
emerge -C man-pages

# Touch hack 
# Solving sandbox bug: IO Failure -- Failed 'touch .unpacked'
mv /bin/touch /bin/oldtouch 
echo '#!/bin/sh' > /bin/touch 
echo 'echo -n >> "$1"' >> /bin/touch 
chmod +x /bin/touch 

# Full update 
emerge -DuN world

# Merge in all /etc updates 
echo "-5" | etc-update 

# Optional 
# Recommended packages 
# Admin tools 
emerge sudo syslog-ng chkrootkit eix vixie-cron 

# Networking 
emerge iptraf netcat nmap tcpdump traceroute iptables dhcpcd ntp 

# Dev tools 
emerge ipython git subversion scipy screen vim unzip links app-text/tree

# Servers/DB
emerge mysql apache lighttpd


# Create user 
#useradd -m -G users,wheel guest
#passwd guest

# Create eix database
#eix-update 



