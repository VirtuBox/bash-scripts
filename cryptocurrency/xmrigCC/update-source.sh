#!/bin/bash

release=1.8.5

# stop xmrigcc
sudo systemctl stop xmrigcc


##################################
# Install gcc7 or gcc8 from PPA
##################################
# gcc7 for nginx stable on Ubuntu 16.04 LTS
# gcc8 for nginx mainline on Ubuntu 16.04 LTS & 18.04 LTS

# Checking lsb_release package
if [ ! -x /usr/bin/lsb_release ]; then
    sudo apt-get -y install lsb-release | sudo tee -a /tmp/nginx-ee.log 2>&1
fi

# install gcc-7
distro_version=$(lsb_release -sc)


    if [ "$distro_version" == "bionic" ] && [ ! -f /etc/apt/sources.list.d/jonathonf-ubuntu-gcc-bionic.list ]; then
        apt-get install software-properties-common -y
        add-apt-repository -y ppa:jonathonf/gcc
        apt-get update
        elif [ "$distro_version" == "xenial" ] && [ ! -f /etc/apt/sources.list.d/jonathonf-ubuntu-gcc-xenial.list ]; then
        apt-get install software-properties-common -y
        add-apt-repository -y ppa:jonathonf/gcc
        apt-get update
    fi
    if [ ! -x /usr/bin/gcc-7 ]; then
    apt-get install gcc-7 g++-7 -y
    fi
    export CC="/usr/bin/gcc-7"
    export CXX="/usr/bin/gc++-7"





if [ ! -d /etc/boost ]; then
cd /etc || exit 1
wget https://dl.bintray.com/boostorg/release/1.67.0/source/boost_1_67_0.tar.bz2
/bin/tar xfj boost_1_67_0.tar.bz2 && rm -f boost_1_67_0.tar.bz2
mv boost_1_67_0 boost
cd boost || exit 1
./bootstrap.sh --with-libraries=system
./b2 --toolset=gcc-7
fi

cd /etc/xmrigCC || exit 1

# get the last release
git fetch
git checkout $release

# compile xmrigcc
make clean
cmake . -DCMAKE_C_COMPILER=gcc-7 -DCMAKE_CXX_COMPILER=g++-7 -DBOOST_ROOT=/etc/boost
make -j "$(nproc)"

sudo wget -O /lib/systemd/system/xmrigcc.service https://raw.githubusercontent.com/VirtuBox/bash-scripts/master/cryptocurrency/xmrigCC/xmrigcc.service
sudo systemctl daemon-reload

# restart xmrigcc
sudo service xmrigcc start
