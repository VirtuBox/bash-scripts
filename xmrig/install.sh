#!/bin/bash

# xmrig install script for Ubuntu 16.04 LTS
#
# 1) download the script
# 2) make the script executable with : chmod +x install.sh
# 3) execute it :  ./install.sh
# 4) edit default config.json file (pool address, wallet address)
# 5) start xmrig : sudo systemctl start xmrig.service
# 

# install prerequisites

sudo apt-get update
sudo apt-get install git build-essential cmake libuv1-dev libmicrohttpd-dev -y

# install gcc-7

sudo add-apt-repository ppa:jonathonf/gcc-7.1 -y
sudo apt-get update
sudo apt-get install gcc-7 g++-7  -y

# download xmrig

cd /etc || exit
sudo git clone https://github.com/xmrig/xmrig.git

# set current user as owner
sudo chown -R $USER:$USER xmrig

# build xmrig
cd xmrig || exit
mkdir build
cd build || exit
cmake .. -DCMAKE_C_COMPILER=gcc-7 -DCMAKE_CXX_COMPILER=g++-7
make -j "$(nproc)"

# create xmrig systemd service

cat <<EOF >xmrig.service
[Unit]
Description=xmrig Daemon

[Service]
ExecStart=/etc/xmrig/build/xmrig
StandardOutput=null

[Install]
WantedBy=multi-user.target
Alias=xmrig.service
EOF

# move xmrig.service to systemd

sudo mv xmrig.service /lib/systemd/system/xmrig.service

# enable HugePage
echo 'vm.nr_hugepages=128' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# enable xmrig service
sudo systemctl enable xmrig.service
