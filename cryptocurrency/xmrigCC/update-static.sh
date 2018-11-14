#!/bin/bash

release=https://github.com/Bendr0id/xmrigCC/releases/download/1.8.2/xmrigCC-1.8.2-with_tls-gcc7-linux-static-miner_only-arm64.tar.gz


cd /etc/xmrigCC || exit 1
service xmrigcc stop
wget -O xmrigcc.tar.gz $release
mv config.json c
tar -xzf xmrigcc.tar.gz
rm xmrigcc.tar.gz
rm config.json
mv c config.json
service xmrigcc start


