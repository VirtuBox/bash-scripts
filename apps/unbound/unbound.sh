#!/usr/bin/env bash

apt-get update && apt-get install unbound -y

wget https://www.internic.net/domain/named.cache -O /var/lib/unbound/root.hints

chown unbound: /var/lib/unbound/root.hints
chmod 644 /var/lib/unbound/root.hints

wget -O /etc/unbound/unbound.conf.d/dns.conf https://raw.githubusercontent.com/VirtuBox/bash-scripts/master/apps/unbound/dns.conf


touch /var/log/unbound.log
chown unbound: /var/log/unbound.log

service unbound restart
