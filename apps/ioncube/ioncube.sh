#!/bin/bash

if [ ! -z $1 ]; then
    PHP_VER=$1
else
    PHP_INI=$(php -i | grep "Loaded Configuration File" | awk -F "=> " '{print $2}')
    PHP_VER=$(echo $PHP_INI | awk -F "/" '{print $4}')
fi

EXTENSION_DIR=$(/usr/bin/php$PHP_VER -i | grep extension_dir | awk -F "=> " '{print $2}')

if [ -f ioncube_loaders_lin_x86-64.tar.gz ]; then
    rm ioncube_loaders_lin_x86-64.tar.gz
fi
if [ -d ioncube ]; then
    rm -rf ioncube
fi

wget -q https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
tar -xvzf ioncube_loaders_lin_x86-64.tar.gz
rm ioncube_loaders_lin_x86-64.tar.gz
cd ioncube || exit 1

cp ioncube_loader_lin_$PHP_VER.so $EXTENSION_DIR -f

FPM_CHECK=$(grep "zend_extension=ioncube_loader_lin_$PHP_VER.so" -r /etc/php/7.2/fpm/conf.d)
CLI_CHECK=$(grep "zend_extension=ioncube_loader_lin_$PHP_VER.so" -r /etc/php/7.2/cli/conf.d)
if [ -z "FPM_CHECK" ]; then
    echo "zend_extension=ioncube_loader_lin_$PHP_VER.so" >/etc/php/$PHP_VER/fpm/conf.d/00-ioncube-loader.ini
fi
if [ -z "CLI_CHECK" ]; then
    echo "zend_extension=ioncube_loader_lin_$PHP_VER.so" >/etc/php/$PHP_VER/cli/conf.d/00-ioncube-loader.ini
fi

service php$PHP_VER-fpm restart
