#!/bin/bash

# install acme.sh if needed
echo ""
echo "checking if acme.sh is already installed"
echo ""
if [ ! -f ~/.acme.sh/acme.sh ]; then
    echo ""
    echo "installing acme.sh"
    echo ""
    wget -O - https://get.acme.sh | sh
fi

echo ""
echo "checking if dig is available"
echo ""
if [ ! -x /usr/bin/dig ]; then
    apt-get install bind9-host -y >>/dev/null
fi

NET_INTERFACES_WAN=$(ip -4 route get 8.8.8.8 | grep -oP "dev [^[:space:]]+ " | cut -d ' ' -f 2)
MY_IP=$(ip -4 address show ${NET_INTERFACES_WAN} | grep 'inet' | sed 's/.*inet \([0-9\.]\+\).*/\1/')
MY_HOSTNAME=$(/bin/hostname -f)
MY_HOSTNAME_IP=$(/usr/bin/dig +short @8.8.8.8 "$MY_HOSTNAME")

if [[ "$MY_IP" = "$MY_HOSTNAME_IP" ]]; then

    [ ! -f /etc/systemd/system/multi-user.target.wants/nginx.service ] && {

        sudo systemctl enable nginx.service
    }

    sudo apt install socat -y

    [ ! -f $HOME/.acme.sh/${MY_HOSTNAME}_ecc/fullchain.cer ] && {

        $HOME/.acme.sh/acme.sh --issue -d $MY_HOSTNAME --keylength ec-384 --standalone --pre-hook "service nginx stop " --post-hook "service nginx start"
    }

    if [ -d /etc/letsencrypt/live/$MY_HOSTNAME ]; then
        rm -rf /etc/letsencrypt/live/$MY_HOSTNAME/*
    else
        mkdir -p /etc/letsencrypt/live/$MY_HOSTNAME
    fi
    [ -f $HOME/.acme.sh/${MY_HOSTNAME}_ecc/fullchain.cer ] && {
        # install the cert and reload nginx
        $HOME/.acme.sh/acme.sh --install-cert -d ${MY_HOSTNAME} --ecc \
            --cert-file /etc/letsencrypt/live/${MY_HOSTNAME}/cert.pem \
            --key-file /etc/letsencrypt/live/${MY_HOSTNAME}/key.pem \
            --fullchain-file /etc/letsencrypt/live/${MY_HOSTNAME}/fullchain.pem \
            --reloadcmd "systemctl enable nginx.service && service nginx restart"
    }

    if [ -f /etc/letsencrypt/live/${MY_HOSTNAME}/fullchain.pem ] && [ -f /etc/letsencrypt/live/${MY_HOSTNAME}/key.pem ]; then

        sed -i "s/ssl_certificate \/var\/www\/22222\/cert\/22222.crt;/ssl_certificate \/etc\/letsencrypt\/live\/${MY_HOSTNAME}\/fullchain.pem;/" /etc/nginx/sites-available/22222
        sed -i "s/ssl_certificate_key \/var\/www\/22222\/cert\/22222.key;/ssl_certificate_key    \/etc\/letsencrypt\/live\/${MY_HOSTNAME}\/key.pem;/" /etc/nginx/sites-available/22222
    fi
    service nginx reload

fi
