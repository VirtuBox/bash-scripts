#!/bin/bash

release=1.6.0

# stop xmrigcc
sudo systemctl stop xmrigcc 

cd /etc/xmrigCC || exit

# get the last release
git fetch
git checkout $release

# compile xmrigcc
cmake . -DCMAKE_C_COMPILER=gcc-7 -DCMAKE_CXX_COMPILER=g++-7 -DBOOST_ROOT=~/boost_1_67_0
make -j "$(nproc)"

# restart xmrigcc
service xmrigcc start
