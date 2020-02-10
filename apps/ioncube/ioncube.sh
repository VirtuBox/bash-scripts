#!/usr/bin/env bash

# check if a command exist
command_exists() {
    command -v "$@" >/dev/null 2>&1
}

if ! command_exists curl; then
    "curl isn't installed and is required"
    exit 1
fi

cd /tmp || exit 1
rm -rf /tmp/ioncube

if [ -n "$1" ]; then
    if [ -x "/usr/bin/php$1" ]; then
        PHP_VER="$1"
    else
        echo "php$1 isn't installed"
        exit 1
    fi
else
    if [ -x "/usr/bin/php" ]; then
        PHP_VER=$(readlink -f /etc/alternatives/php | awk -F "/usr/bin/php" '{print $2}')
    fi
fi

if [ "$PHP_VER" = "7.4" ]; then
    echo "PHP 7.4 is not supported by ioncube loader yet"
    exit 1
fi

EXTENSION_DIR=$(/usr/bin/php${PHP_VER} -i | grep extension_dir | awk -F "=> " '{print $2}' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

curl -sSL https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz | tar -xzf - -C /tmp
cd /tmp/ioncube || exit 1
cp ioncube_loader_lin_${PHP_VER}.so "${EXTENSION_DIR}/" -f

if [ ! -f "${EXTENSION_DIR}/ioncube_loader_lin_${PHP_VER}.so" ]; then
    exit 1
fi

FPM_CHECK=$(grep "ioncube" -R /etc/php/${PHP_VER}/fpm/conf.d)
CLI_CHECK=$(grep "ioncube" -R /etc/php/${PHP_VER}/cli/conf.d)
MODS_AVAILABLE=$(grep "ioncube" -r /etc/php/${PHP_VER}/mods-available)
if ! grep -q "ioncube" -r /etc/php/${PHP_VER}/mods-available; then
    echo -e "; configuration for php ioncube loader\n; priority=00\nzend_extension=ioncube_loader_lin_${PHP_VER}.so" >/etc/php/${PHP_VER}/mods-available/ioncube-loader.ini
fi
if ! grep -q "ioncube" -R /etc/php/${PHP_VER}/fpm/conf.d; then
    phpenmod -v "$PHP_VER" ioncube-loader
fi
if ! grep -q "ioncube" -R /etc/php/${PHP_VER}/cli/conf.d; then
    phpenmod -v "$PHP_VER" ioncube-loader
fi

service php${PHP_VER}-fpm restart
cd || exit 1
rm -rf /tmp/ioncube
