#!/bin/bash

mkdir -p /etc/opendkim/keys/$DOMAIN/
opendkim-genkey -s 202109 -d $DOMAIN -D /etc/opendkim/keys/$DOMAIN/
chown -R opendkim:opendkim /etc/opendkim/keys/$DOMAIN/
echo "202109._domainkey.$DOMAIN $DOMAIN:202109:/etc/opendkim/keys/$DOMAIN/202109.private" >> /etc/opendkim/KeyTable
echo "*@$DOMAIN 202109._domainkey.$DOMAIN" >> /etc/opendkim/SigningTable
echo '127.0.0.1' >> /etc/opendkim/TrustedHosts
echo '::1' >> /etc/opendkim/TrustedHosts
echo "$PUBLIC_IP" >> /etc/opendkim/TrustedHosts
echo "$DOMAIN" >> /etc/opendkim/TrustedHosts
echo "mail.$DOMAIN" >> /etc/opendkim/TrustedHosts

echo "$DOMAIN" > /etc/mailname
sed -i "s/_DOMAIN_/$DOMAIN/g" /etc/opendkim.conf
sed -i "s/_DOMAIN_/$DOMAIN/g" /etc/postfix/main.cf
sed -i "s/ _PUBLIC_IP_/$PUBLIC_IP/g" /etc/postfix/main.cf


service postfix start
postfix reload
service opendkim start
certbot certonly --standalone -d $DOMAIN  --register-unsafely-without-email --agree-tos
cd gophish
ssl_cert="/etc/letsencrypt/live/${DOMAIN}/fullchain.pem"
ssl_key="/etc/letsencrypt/live/${DOMAIN}/privkey.pem"
cp $ssl_cert ${DOMAIN}.crt
cp $ssl_key ${DOMAIN}.key
sed -i "s/gophish_admin.crt/${DOMAIN}.crt/g" config.json
sed -i "s/gophish_admin.key/${DOMAIN}.key/g" config.json
sed -i 's/"use_tls" : false/"use_tls" : true/g' config.json
sed -i "s/example.crt/${DOMAIN}.crt/g" config.json
sed -i "s/example.key/${DOMAIN}.key/g" config.json
./gophish
