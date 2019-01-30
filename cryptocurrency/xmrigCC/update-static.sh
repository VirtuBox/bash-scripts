#!/bin/bash

release="https://github.com/Bendr0id/xmrigCC/releases/download/1.8.12/xmrigCC-1.8.12-with_tls-gcc7-linux-static-miner_only-x64.tar.gz"


cd /etc/xmrigCC || exit 1
sudo service xmrigcc stop
wget -O xmrigcc.tar.gz "$release"
mv config.json c
/bin/tar -xzf xmrigcc.tar.gz
rm -f xmrigcc.tar.gz
rm -f config.json
mv c config.json

sudo service xmrigcc start


