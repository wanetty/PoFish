FROM debian:latest

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt upgrade -y
RUN apt install postfix git golang gcc opendkim opendkim-tools certbot -y

COPY postfix/main.cf /etc/postfix/main.cf
COPY postfix/master.cf	/etc/postfix/master.cf
RUN echo "$DOMAIN" > /etc/mailname


WORKDIR /opt
RUN git clone https://github.com/gophish/gophish.git
RUN find . -type f -exec sed -i.bak 's/X-Gophish-Contact/X-Contact/g' {} +
RUN find . -type f -exec sed -i.bak 's/X-Gophish-Signature/X-Signature/g' {} +
RUN  sed -i 's/\"gophish\"/\"IGNORE\"/g' gophish/config/config.go
WORKDIR /opt/gophish
RUN go build
RUN sed -i "s/0.0.0.0:80/0.0.0.0:443/g" config.json
RUN sed -i "s/127.0.0.1:3333/0.0.0.0:3333/g" config.json
WORKDIR /opt
COPY dkim/opendkim.conf /etc/opendkim.conf
COPY start.sh /opt/start.sh

RUN chmod +x start.sh

ENTRYPOINT ["/bin/bash","start.sh"]

