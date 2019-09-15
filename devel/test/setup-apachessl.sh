#!/bin/bash

#certvariant='certbot'

sudo apt-get install apache2 libapache2-mod-php7.0 php7.0 software-properties-common
sudo adduser $USER www-data
sudo chown -R www-data:www-data /var/www
sudo chmod -R g+rwX /var/www
sudo openssl genrsa -out /etc/ssl/private/apache.key

if [ "$certvariant" == "certbot" ]; then
    sudo add-apt-repository ppa:certbot/certbot
    sudo apt-get update
    sudo apt-get install python-certbot-apache
    certbot --apache
else
    sudo openssl req -new -x509 -key /etc/ssl/private/apache.key -days 3650 -sha256 -out /etc/ssl/certs/apache.crt
    a2enmod ssl
    sudo cat <<- 'EndHereDocument' > /etc/apache2/sites-available/ssl.conf
<VirtualHost *:443>
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/apache.crt
    SSLCertificateKeyFile /etc/ssl/private/apache.key

    # Pfad zu den Webinhalten
    DocumentRoot /var/www/html/
</VirtualHost>
EndHereDocument
fi

sudo service apache2 force-reload

sudo apt-get install -y wireshark
sudo adduser $USER wireshark
sudo groupadd pcap
sudo usermod -a -G pcap $USER
sudo chgrp pcap /usr/sbin/tcpdump
sudo chmod 750 /usr/sbin/tcpdump
sudo setcap cap_net_raw,cap_net_admin=eip /usr/sbin/tcpdump
