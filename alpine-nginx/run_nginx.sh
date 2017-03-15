#!/bin/bash

# Fix nginx error on startup...
if [ ! -d "/run/nginx" ]; then
  mkdir /run/nginx
fi

# DOMAINS => example.com,www.example.com
if [ "$DOMAINS" != "" ]; then
  IFS=',' read -r -a ADDR <<< "$DOMAINS"
  if [ ! -d "/etc/letsencrypt/live/${ADDR[0]}" ]; then
    # Replace default.conf
    cp /etc/nginx/conf.d/default.conf.new /etc/nginx/conf.d/default.conf
    nginx
    certbot certonly --verbose --noninteractive --quiet --standalone --agree-tos --register-unsafely-without-email --webroot-path /var/lib/nginx/html -domains "${DOMAINS}"
    
    
  fi
  # Generate Strong Diffie-Hellman Group
  if [ -f "/etc/ssl/certs/dhparam.pem" ]; then
    openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
  fi
else
  certbot renew
fi

/usr/sbin/nginx -g "daemon off;"
