#!/bin/bash

release=1.8.1

# stop xmrigcc
sudo systemctl stop xmrigcc 



if [ ! -f /etc/apt/sources.list.d/jonathonf-ubuntu-gcc-7_1-xenial.list ]; then
                apt-get install software-properties-common -y
                add-apt-repository ppa:jonathonf/gcc-7.1 -y
                apt-get update
                apt-get install gcc-7 g++-7 -y
                export CC="/usr/bin/gcc-7"
                export CXX="/usr/bin/gc++-7"
fi


                
if [ -d /etc/boost ]; then
cd /etc || exit
rm -rf boost
wget https://dl.bintray.com/boostorg/release/1.67.0/source/boost_1_67_0.tar.bz2
tar xvfj boost_1_67_0.tar.bz2 && rm -rf boost_1_67_0.tar.bz2
mv boost_1_67_0 boost
cd boost || exit
./bootstrap.sh --with-libraries=system
./b2 --toolset=gcc-7
fi

cd /etc/xmrigCC || exit

# get the last release
git fetch
git checkout $release

# compile xmrigcc
cmake . -DCMAKE_C_COMPILER=gcc-7 -DCMAKE_CXX_COMPILER=g++-7 -DBOOST_ROOT=/etc/boost
make -j "$(nproc)"

# restart xmrigcc
service xmrigcc start
