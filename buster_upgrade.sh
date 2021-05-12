#!/bin/bash
# script to update from Debian 7 Wheezy to Debian 9 Buster
 
set -e

export DEBIAN_FRONTEND=noninteractive
declare -r APT_GET_OPTIONS="--quiet --assume-yes -o Acquire::Retries=10 -o APT::Force-LoopBreak=1 -o Dpkg::Options::="--force-confnew""
declare -r LANGBASH=C

service mysql stop
aptitude -y purge $(dpkg -l | grep percona | awk '{print $2}')

cat <<EOF > /usr/sbin/policy-rc.d
#!/bin/sh
exit 101
EOF
chmod ugo+x /usr/sbin/policy-rc.d

cat <<EOF >/etc/apt/sources.list
deb http://deb.debian.org/debian/ jessie main contrib non-free
deb http://security.debian.org/ jessie/updates main contrib non-free
EOF

apt-get update
apt-get ${APT_GET_OPTIONS} install dpkg apt xz-utils

cat <<EOF >/etc/apt/sources.list
deb [arch=amd64] http://ftp2.de.debian.org/debian buster main contrib non-free
deb [arch=amd64] http://security.debian.org/ buster/updates main contrib non-free
EOF

apt-get update
apt-get ${APT_GET_OPTIONS} install debian-archive-keyring

set +e
apt-get ${APT_GET_OPTIONS} install dpkg apt xz-utils libsasl2-2 libsasl2-modules-db
apt-get -f -y install
set -e

dpkg -P --force-all sysvinit
apt-get ${APT_GET_OPTIONS} dist-upgrade
apt-get ${APT_GET_OPTIONS} dist-upgrade
apt-get ${APT_GET_OPTIONS} install default-mysql-server libcrypto++6 libdouble-conversion1 libpcre2-16-0

mkdir -p /etc/systemd/system/mariadb.service.d
cat <<EOF >/etc/systemd/system/mariadb.service.d/override.conf
[Service]
ProtectSystem=off
PrivateDevices=false
ProtectHome=false
EOF

apt-get -y --purge remove $(dpkg -l | grep "deb7\|deb8\|wheezy\|jessie" | awk '{ print $2 }')
apt-get -y --purge remove nagios-plugins-common
apt-get -y --purge autoremove
apt-get -y --purge remove $(dpkg -l | grep "^rc" | awk '{ print $2 }')
apt update
apt -y install exim4 iputils-ping

rm /usr/sbin/policy-rc.d
reboot
