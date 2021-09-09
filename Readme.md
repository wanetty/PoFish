## POFISH

### Execute
```docker run --rm -it --name pofish -p 80:80 -p 3333:3333 --env DOMAIN=<yourdomain> --env PUBLIC_IP=<your_public_ip> pofish start.sh```

### Get DKIM for DNS

```sudo docker exec pofish cat /etc/opendkim/keys/<yourdomain>/202109.txt```

# More info

https://wanetty.github.io/tools/pofish
