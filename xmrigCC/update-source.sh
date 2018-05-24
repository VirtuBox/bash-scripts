#!/bin/bash

release=1.6.3

# stop xmrigcc
sudo systemctl stop xmrigcc 

if [ ! -d /etc/boost ]; then
cd /etc || exit
wget https://dl.bintray.com/boostorg/release/1.67.0/source/boost_1_67_0.tar.bz2
tar xvfj boost_1_67_0.tar.bz2 && rm -rf boost_1_67_0.tar.bz2
mv boost_1_67_0 boost
cd boost || exit
./bootstrap.sh --with-libraries=system
./b2
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
