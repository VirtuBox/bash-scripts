#!/bin/bash

# check if wp-cli is installed
# if not, download it
if [ -z "$(command -v wp)" ]; then
    wget -O wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp
    WPCLI="./wp"
else
    WPCLI="wp"
fi

# check if wp is-installed
WP_CHECK=$($WPCLI core is-installed)
if [ -z "$WP_CHECK" ]; then

    SITE_URL=$($WPCLI option get siteurl)
    SITE_DOMAIN=$($WPCLI option get siteurl | awk -F "//" '{print $2}')

    # replace site url with https
    $WPCLI search-replace \
    "$SITE_URL" \
    "https://$SITE_DOMAIN" \
    --skip-columns=guid --skip-tables=wp_users

    # replace encoded site url with https
    $WPCLI search-replace \
    "http:\/\/$SITE_DOMAIN" \
    "https:\/\/$SITE_DOMAIN" \
    --skip-columns=guid  --skip-tables=wp_users

else
    echo "no wordpress instance found"
    exit 1
fi