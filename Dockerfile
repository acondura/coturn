FROM alpine:latest

# Initial updates
RUN apk update && \
    apk upgrade && \
    rm -rf /var/cache/apk/*

# Install packages
RUN apk add --no-cache \
    # Init related
    tini \
    openrc \
    busybox-initscripts \
    # Required packages
    bash \
    busybox-suid \
    composer \
    curl \
    git \
    grep \
    inotify-tools \
    shadow \
    supervisor \
    vim \
    coturn \
    certbot

# Syslog option '-Z' was changed to '-t', change this in /etc/conf.d/syslog so that syslog can start
# https://gitlab.alpinelinux.org/alpine/aports/-/issues/9279
RUN sed -i 's/SYSLOGD_OPTS="-Z"/SYSLOGD_OPTS="-t"/g' /etc/conf.d/syslog

# Supercronic package - cron enhancement
RUN export SUPERCRONIC_LATEST=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/aptible/supercronic/releases/latest) && \
    export SUPERCRONIC_BASENAME=$(basename ${SUPERCRONIC_LATEST}) && \
    export SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/${SUPERCRONIC_BASENAME}/supercronic-linux-amd64 && \
    export SUPERCRONIC=supercronic-linux-amd64 && \
    curl -fsSLO "$SUPERCRONIC_URL" && \
    chmod +x "$SUPERCRONIC" && \
    mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" && \
    ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic

# Accept incoming HTTP requests
EXPOSE 443

# Supervisor prep
RUN mkdir -p /etc/supervisor/includes
# Main supervisor config
COPY supervisor/supervisord.conf /etc/supervisor
# Supervisor programs
COPY supervisor/includes/*.conf /etc/supervisor/includes/
# Services start script (and related fixes)
COPY run/start.sh /

# Initialize services (Cron, PHP-FPM and Apache)
CMD bash /start.sh