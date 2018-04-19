#!/bin/bash

release=v2.6.0-beta2

# stop xmrig
sudo systemctl stop xmrig 

cd /etc/xmrig || exit

# get the last release
git fetch
git checkout $release

# compile xmrig
cmake . -DCMAKE_C_COMPILER=gcc-7 -DCMAKE_CXX_COMPILER=g++-7
make -j "$(nproc)"

# restart xmrig
service xmrig start
