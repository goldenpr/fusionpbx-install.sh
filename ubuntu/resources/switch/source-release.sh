#!/bin/sh

#move to script directory so all relative paths work
cd "$(dirname "$0")"

#includes
. ../config.sh

#upgrade packages
apt update && apt upgrade -y

# install dependencies
apt -y install autoconf automake devscripts g++ git-core libncurses5-dev libtool make libjpeg-dev pkg-config flac
apt -y install libgdbm-dev libdb-dev gettext sudo equivs mlocate git dpkg-dev devscripts libtiff5-dev libperl-dev

# additional dependencies
apt install -y sqlite3 swig3.0 unzip sox wget

#we are about to move out of the executing directory so we need to preserve it to return after we are done
CWD=$(pwd)
echo "Using version $switch_version"
cd /usr/src
#git clone -b v1.8 https://freeswitch.org/stash/scm/fs/freeswitch.git /usr/src/freeswitch
wget http://files.freeswitch.org/freeswitch-releases/freeswitch-$switch_version.zip
unzip freeswitch-$switch_version.zip
rm -R freeswitch
mv freeswitch-$switch_version freeswitch
cd /usr/src/freeswitch

# bootstrap is needed if using git
#./bootstrap.sh -j

# enable required modules
sed -i /usr/src/freeswitch/modules.conf -e s:'#applications/mod_avmd:applications/mod_avmd:'
sed -i /usr/src/freeswitch/modules.conf -e s:'#applications/mod_callcenter:applications/mod_callcenter:'
sed -i /usr/src/freeswitch/modules.conf -e s:'#applications/mod_cidlookup:applications/mod_cidlookup:'
sed -i /usr/src/freeswitch/modules.conf -e s:'#applications/mod_memcache:applications/mod_memcache:'
sed -i /usr/src/freeswitch/modules.conf -e s:'#applications/mod_curl:applications/mod_curl:'
sed -i /usr/src/freeswitch/modules.conf -e s:'#formats/mod_shout:formats/mod_shout:'

# prepare the build
#./configure --prefix=/usr/local/freeswitch --enable-core-pgsql-support --disable-fhs
./configure -C --enable-portable-binary --disable-dependency-tracking \
--prefix=/usr --localstatedir=/var --sysconfdir=/etc \
--with-openssl --enable-core-pgsql-support

# compile and install
make
make install
make sounds-install moh-install
make hd-sounds-install hd-moh-install
make cd-sounds-install cd-moh-install

#move the music into music/default directory
mkdir -p /usr/share/freeswitch/sounds/music/default
mv /usr/share/freeswitch/sounds/music/*000 /usr/share/freeswitch/sounds/music/default

#return to the executing directory
cd $CWD
