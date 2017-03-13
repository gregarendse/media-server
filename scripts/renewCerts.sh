#!/bin/sh 

# This script renews all the Let's Encrypt certificates with a validity < 30 days
# Taken from https://letsecure.me/secure-web-deployment-with-lets-encrypt-and-nginx/

if ! letsencrypt renew > /var/log/letsencrypt/renew.log 2>&1 ; then
	echo Automated renewal failed:
	cat /var/log/letsencrypt/renew.log
	exit 1
fi

/usr/sbin/nginx -t && /usr/sbin/nginx -s reload
