#!/usr/bin/env bash
PHPMYADMIN_VERSION="4.9.0.1"

if [ "$(id -u)" != "0" ]; then
	echo "Error: You must be root to run this script, please use the root user to install the software."
	echo ""
	echo "Use 'sudo su - root' to login as root"
	exit 1
fi

cd /var/www/22222/htdocs/db/ || exit 1
wget -O phpmyadmin.zip https://files.phpmyadmin.net/phpMyAdmin/$PHPMYADMIN_VERSION/phpMyAdmin-$PHPMYADMIN_VERSION-all-languages.zip

unzip phpmyadmin.zip && rm phpmyadmin.zip
mv pma/config.inc.php .
cp -rf phpMyAdmin-$PHPMYADMIN_VERSION-all-languages/* pma/
mv config.inc.php pma/
rm -rf phpMyAdmin-$PHPMYADMIN_VERSION-all-languages

sudo chown -R www-data:www-data pma
