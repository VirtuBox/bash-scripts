#!/bin/bash

cd /etc || exit
wget https://dl.bintray.com/boostorg/release/1.67.0/source/boost_1_67_0.tar.bz2
tar xvfj boost_1_67_0.tar.bz2
mv boost_1_67_0 boost
cd boost || exit
./bootstrap.sh --with-libraries=system
./b2
