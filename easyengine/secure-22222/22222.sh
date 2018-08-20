#!/bin/bash



ee-acme-22222() {

    MY_HOSTNAME=$(hostname -f)
    MY_IP=$(curl -s v4.vtbox.net)
    MY_HOSTNAME_IP=$(dig +short @8.8.8.8 $MY_HOSTNAME)

    if [[ "$MY_IP" = "$MY_HOSTNAME_IP" ]]
    then

        if [ ! -f /etc/systemd/system/multi-user.target.wants/nginx.service ]
        then
            sudo systemctl enable nginx.service
        fi

        sudo apt install socat -y

        if [ ! -f  $HOME/.acme.sh/${MY_HOSTNAME}_ecc/fullchain.cer ]
        then
            $HOME/.acme.sh/acme.sh --issue -d $MY_HOSTNAME --keylength ec-384 --standalone --pre-hook "service nginx stop " --post-hook "service nginx start"
        fi

        if [ -d /etc/letsencrypt/live/$MY_HOSTNAME ]
        then
            rm -rf /etc/letsencrypt/live/$MY_HOSTNAME/*
        else
            mkdir -p /etc/letsencrypt/live/$MY_HOSTNAME
        fi

        # install the cert and reload nginx
        $HOME/.acme.sh/acme.sh --install-cert -d ${MY_HOSTNAME} --ecc \
        --cert-file /etc/letsencrypt/live/${MY_HOSTNAME}/cert.pem \
        --key-file /etc/letsencrypt/live/${MY_HOSTNAME}/key.pem \
        --fullchain-file /etc/letsencrypt/live/${MY_HOSTNAME}/fullchain.pem \
        --reloadcmd "systemctl reload nginx.service"

        if [ -f /etc/letsencrypt/live/${MY_HOSTNAME}/fullchain.pem ] && [ -f /etc/letsencrypt/live/${MY_HOSTNAME}/key.pem ]
        then
            sed -i "s/ssl_certificate \/var\/www\/22222\/cert\/22222.crt;/ssl_certificate \/etc\/letsencrypt\/live\/${MY_HOSTNAME}\/fullchain.pem;/" /etc/nginx/sites-available/22222
            sed -i "s/ssl_certificate_key \/var\/www\/22222\/cert\/22222.key;/ssl_certificate_key    \/etc\/letsencrypt\/live\/${MY_HOSTNAME}\/key.pem;/" /etc/nginx/sites-available/22222
        fi
        service nginx reload

    fi
}

ee-acme-22222