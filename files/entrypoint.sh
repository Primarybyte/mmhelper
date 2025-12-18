#!/bin/sh

set -e

# Set defaults if variables are unset or empty
: "${AUTH_HTTP_URL:=http://localhost:8080}"
: "${AUTH_HTTP_KEY:=changeme}"
: "${MAILER_SERVER_NAME:=localhost}"
: "${MAIL_SERVER_PORT:=2525}"


export AUTH_HTTP_URL AUTH_HTTP_KEY MAILER_SERVER_NAME MAIL_SERVER_PORT


# Check if the NGINX config already exists
if [ -f /etc/nginx/nginx.conf.template ]; then
    echo "Generating nginx.conf from template..."
    envsubst '$AUTH_HTTP_URL $AUTH_HTTP_KEY $MAILER_SERVER_NAME $MAIL_SERVER_PORT' \
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