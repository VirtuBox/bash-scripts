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

sudo add-apt-repository ppa:jonathonf/gcc-7.1 -y
sudo apt-get update
sudo apt-get install gcc-7 g++-7  -y

# install libboost if needed

if [ ! -d /etc/boost ]; then
cd /etc || exit
wget https://dl.bintray.com/boostorg/release/1.67.0/source/boost_1_67_0.tar.bz2
tar xvfj boost_1_67_0.tar.bz2 && rm -rf boost_1_67_0.tar.bz2
mv boost_1_67_0 boost
cd boost || exit
./bootstrap.sh --with-libraries=system
./b2
fi

# download xmrigCC
cd /etc || exit
sudo git clone https://github.com/Bendr0id/xmrigCC.git
sudo chown -R $USER:$USER xmrigCC

# build xmrigCC
cd xmrigCC || exit
cmake . -DCMAKE_C_COMPILER=gcc-7 -DCMAKE_CXX_COMPILER=g++-7 -DBOOST_ROOT=/etc/boost
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


