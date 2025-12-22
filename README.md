# freenginx-mmhelper


## How to run
1. install docker and buildkit
```
apt install docker.io docker-buildx
```


2. Build docker images and run this way:
```
DOCKER_BUILDKIT=1 docker build --rm -t freenginx-mmhelper:1.28 .
```


3. Run as service:

```
docker run -d \
  --name freenginx-mmhelper \
  --restart unless-stopped \
  -p 25:25 \
  -p 465:465 \
  -p 587:587 \
  -e AUTH_HTTP_URL="https://api.example.com:443/authorize" \
  -e AUTH_HTTP_KEY="key_from_app" \
  -e MAILER_SERVER_NAME="mailer-a-smtp.localhost" \
freenginx-mmhelper:1.28 /bin/bash
```

4. How to debug:
```
telnet your.host 25
openssl s_client -starttls smtp -connect your.host:587
openssl s_client -connect your.host:465

```