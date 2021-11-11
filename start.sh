#!/bin/bash


install_ssl_Cert() {
	git clone https://github.com/certbot/certbot.git /opt/letsencrypt > /dev/null 2>&1
	command="/opt/letsencrypt/certbot-auto certonly --standalone $DOMAIN -n --register-unsafely-without-email --agree-tos"
	eval $command

}



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
install_ssl_Cert
cd gophish
./gophish
