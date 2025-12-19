#!/bin/sh

set -e

# Set defaults if variables are unset or empty
: "${AUTH_HTTP_URL:=http://localhost:8080}"
: "${AUTH_HTTP_KEY:=changeme}"
: "${MAIL_SERVER_LOG_LVL:=info}"
: "${MAIL_SERVER_NAME:=localhost}"
: "${MAIL_SERVER_PORT:=25}"
: "${MAIL_SERVER_SSL_PORT:=465}"
: "${MAIL_SERVER_SSL_CERT:=/etc/nginx/to20500101.crt}"
: "${MAIL_SERVER_SSL_KEY:=/etc/nginx/to20500101.key}"


export AUTH_HTTP_URL AUTH_HTTP_KEY MAIL_SERVER_LOG_LVL MAILER_SERVER_NAME MAIL_SERVER_PORT MAIL_SERVER_SSL_PORT MAIL_SERVER_SSL_CERT MAIL_SERVER_SSL_KEY


# Check if the NGINX config already exists
if [ -f /etc/nginx/nginx.conf.template ]; then
    echo "Generating nginx.conf from template..."
    envsubst '$AUTH_HTTP_URL $AUTH_HTTP_KEY $MAIL_SERVER_LOG_LVL $MAILER_SERVER_NAME $MAIL_SERVER_PORT $MAIL_SERVER_SSL_PORT $MAIL_SERVER_SSL_CERT $MAIL_SERVER_SSL_KEY' \
      < /etc/nginx/nginx.conf.template \
      > /etc/nginx/nginx.conf
else
    echo "Using existing nginx.conf"
fi

# exec freenginx -g 'daemon off;'
# exec /usr/sbin/nginx -g 'daemon off;'

# Run NGINX with default CMD

# Run arguments if provided, else run CMD default from Dockerfile
if [ $# -eq 0 ]; then
    # No arguments passed -> use default CMD
    exec /usr/sbin/nginx -g 'daemon off;'
else
    exec "$@"
fi