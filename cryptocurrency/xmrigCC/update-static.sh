#!/bin/bash

release=https://github.com/Bendr0id/xmrigCC/releases/download/1.8.4/xmrigCC-1.8.4-with_tls-gcc7-linux-static-miner_only-x64.tar.gz


cd /etc/xmrigCC || exit 1
sudo service xmrigcc stop
wget -O xmrigcc.tar.gz $release
mv config.json c
/bin/tar -xzf xmrigcc.tar.gz
rm xmrigcc.tar.gz
rm config.json
mv c config.json

sudo wget -O /lib/systemd/system/xmrigcc.service https://raw.githubusercontent.com/VirtuBox/bash-scripts/master/cryptocurrency/xmrigCC/xmrigcc.service
sudo systemctl daemon-reload


sudo service xmrigcc start


