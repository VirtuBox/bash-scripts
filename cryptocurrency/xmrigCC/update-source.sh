#!/bin/bash

release=1.7.0-beta1

# stop xmrigcc
sudo systemctl stop xmrigcc 

# install gcc-8

if [ ! -f /etc/apt/sources.list.d/jonathonf-ubuntu-gcc-8_1-bionic.list ] && [ ! -f /etc/apt/sources.list.d/jonathonf-ubuntu-gcc-8_1-xenial.list ]; then
    
    apt-get install software-properties-common -y
    add-apt-repository ppa:jonathonf/gcc-8.1 -y
    apt-get update
    apt-get install gcc-8 g++-8 -y
    export CC="/usr/bin/gcc-8"
    export CXX="/usr/bin/gc++-8"
fi

#sudo add-apt-repository ppa:jonathonf/gcc-7.1 -y
#sudo apt-get update
#sudo apt-get install gcc-7 g++-7  -y

# install libboost if needed

if [  -d /etc/boost ]; then
rm -rf /etc/boost
cd /etc || exit
wget https://dl.bintray.com/boostorg/release/1.67.0/source/boost_1_67_0.tar.bz2
tar xvfj boost_1_67_0.tar.bz2 && rm -rf boost_1_67_0.tar.bz2
mv boost_1_67_0 boost
cd boost || exit
./bootstrap.sh --with-libraries=system
./b2 --toolset=gcc-8
fi

cd /etc/xmrigCC || exit

# get the last release
git fetch
git checkout $release

# compile xmrigcc
cmake . -DCMAKE_C_COMPILER=gcc-8 -DCMAKE_CXX_COMPILER=g++-8 -DBOOST_ROOT=/etc/boost
make -j "$(nproc)"

# restart xmrigcc
service xmrigcc start
