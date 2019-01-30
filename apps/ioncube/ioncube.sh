#!/bin/bash

cd "$HOME" || exit 1

if [ "$1" ]; then
    PHP_VER="$1"
else
    PHP_VER=$(/usr/bin/php -i | grep "Loaded Configuration File" | awk -F "=> " '{print $2}' | awk -F "/" '{print $4}')
fi

EXTENSION_DIR=$(/usr/bin/php${PHP_VER} -i | grep extension_dir | awk -F "=> " '{print $2}')

rm -f ioncube*.tar.gz
rm -rf ioncube

wget -O ioncube.tar.gz https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
tar -xzf ioncube.tar.gz
rm -f ioncube.tar.gz

cd ioncube || exit 1
cp ioncube_loader_lin_${PHP_VER}.so "$EXTENSION_DIR" -f

FPM_CHECK=$(grep "zend_extension=ioncube_loader_lin_${PHP_VER}.so" -r /etc/php/${PHP_VER}/fpm/conf.d)
CLI_CHECK=$(grep "zend_extension=ioncube_loader_lin_${PHP_VER}.so" -r /etc/php/${PHP_VER}/cli/conf.d)
if [ -z "$FPM_CHECK" ]; then
    echo "zend_extension=ioncube_loader_lin_${PHP_VER}.so" >/etc/php/${PHP_VER}/fpm/conf.d/00-ioncube-loader.ini
fi
if [ -z "$CLI_CHECK" ]; then
    echo "zend_extension=ioncube_loader_lin_${PHP_VER}.so" >/etc/php/${PHP_VER}/cli/conf.d/00-ioncube-loader.ini
fi

service php${PHP_VER}-fpm restart

rm -rf ioncube
