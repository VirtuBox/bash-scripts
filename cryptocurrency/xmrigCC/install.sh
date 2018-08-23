#!/bin/bash

# xmrigCC install script for Ubuntu 16.04 LTS
#
# 1) download the script
# 2) make the script executable with : chmod +x install.sh
# 3) execute it :  ./install.sh
# 4) edit default config.json file (pool address, wallet address)
# 5) start xmrigCC : sudo systemctl start xmrigcc.service
# 

# install prerequisites

sudo apt-get update
sudo apt-get install git build-essential cmake libuv1-dev libmicrohttpd-dev libssl-dev -y

# install gcc-7

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

if [ ! -d /etc/boost ]; then
cd /etc || exit
wget https://dl.bintray.com/boostorg/release/1.67.0/source/boost_1_67_0.tar.bz2
tar xvfj boost_1_67_0.tar.bz2 && rm -rf boost_1_67_0.tar.bz2
mv boost_1_67_0 boost
cd boost || exit
./bootstrap.sh --with-libraries=system
./b2 --toolset=gcc-8
fi

# download xmrigCC
cd /etc || exit
sudo git clone https://github.com/Bendr0id/xmrigCC.git
sudo chown -R $USER:$USER xmrigCC

# build xmrigCC
cd xmrigCC || exit
cmake . -DCMAKE_C_COMPILER=gcc-8 -DCMAKE_CXX_COMPILER=g++-8 -DBOOST_ROOT=/etc/boost
make -j "$(nproc)"

# create xmrigCC systemd service

sudo wget https://raw.githubusercontent.com/VirtuBox/bash-scripts/master/xmrigCC/xmrigcc.service -O  /lib/systemd/system/xmrigcc.service

# enable xmrigCC service
sudo systemctl enable xmrigcc.service

# enable HugePage
echo 'vm.nr_hugepages=128' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# copy default config.json file
cp src/config.json .
cp src/config_cc.json .


