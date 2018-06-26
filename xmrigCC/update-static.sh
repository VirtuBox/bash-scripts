#!/bin/bash

release=https://github.com/Bendr0id/xmrigCC/releases/download/1.6.5/xmrigCC-1.6.5-with_tls-gcc7-linux-static-miner_only-arm64.tar.gz


cd /etc/xmrigCC || exit
service xmrigcc stop
wget $release -O xmrigcc.tar.gz
mv config.json c
tar -xzvf xmrigcc.tar.gz
rm xmrigcc.tar.gz
rm config.json
mv c config.json
service xmrigcc start


