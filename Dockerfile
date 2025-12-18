# Dockerfile: FreeNGINX 1.28.x with mail (POP3/IMAP/SMTP proxy) module support
# Multi-stage build: compile in builder stage, ship minimal runtime

############################
# Builder stage
############################
FROM debian:bookworm AS builder

ARG FREENX_VERSION=1.28.0
ARG FREENX_SHA1=9cf7f675acd128f1ccebef7389b887bf6562a550


ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    wget \
    gettext-base \
    libpcre3-dev \
    zlib1g-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src

RUN wget -O freenginx.tar.gz https://freenginx.org/download/freenginx-${FREENX_VERSION}.tar.gz \
    && echo "${FREENX_SHA1} freenginx.tar.gz" | sha1sum -c - \
    && tar -xzf freenginx.tar.gz



WORKDIR /usr/src/freenginx-${FREENX_VERSION}

RUN ./configure \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_realip_module \
    --with-http_stub_status_module \
    --with-mail \
    --with-mail_ssl_module

RUN make -j$(nproc) && make install


############################
# Runtime stage
############################
FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# Runtime libraries only
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpcre3 \
    zlib1g \
    libssl3 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy nginx executable, modules, and support files
COPY --from=builder /usr/sbin/nginx /usr/sbin/nginx
COPY --from=builder /etc/nginx /etc/nginx

# no libs in static build
# COPY --from=builder /usr/lib/nginx /usr/lib/nginx

# copy gettext templater
COPY --from=builder /usr/bin/envsubst /usr/bin/envsubst

# Create required runtime directories
RUN mkdir -p /var/log/nginx /var/run /var/mail

EXPOSE 25 2525

STOPSIGNAL SIGQUIT

# Copy conf files
COPY ./files/nginx.conf.template /etc/nginx/nginx.conf.template
COPY ./files/to20500101.crt /etc/nginx/to20500101.crt
COPY ./files/to20500101.key /etc/nginx/to20500101.key


# Copy the entrypoint script
COPY ./files/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Optional: default CMD can still provide arguments to the entrypoint
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]
# CMD []



