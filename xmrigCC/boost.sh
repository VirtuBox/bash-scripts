#!/bin/bash

wget https://dl.bintray.com/boostorg/release/1.67.0/source/boost_1_67_0.tar.bz2
tar xvfj boost_1_67_0.tar.bz2
cd boost_1_67_0
./bootstrap.sh --with-libraries=system
./b2
