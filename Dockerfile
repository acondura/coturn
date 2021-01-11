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
#RUN export SUPERCRONIC_LATEST=$(curl -Ls -o /dev/null -w %{url_effective} https://github.com/aptible/supercronic/releases/latest) && \
#    export SUPERCRONIC_BASENAME=$(basename ${SUPERCRONIC_LATEST}) && \
#    export SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/${SUPERCRONIC_BASENAME}/supercronic-linux-amd64 && \
#    export SUPERCRONIC=supercronic-linux-amd64 && \
#    curl -fsSLO "$SUPERCRONIC_URL" && \
#    chmod +x "$SUPERCRONIC" && \
#    mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" && \
#    ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic

### Local bash distro
RUN cd ~/ && bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" \
    # Use a theme that clearly shows user, path and git branch
    sed -i 's/OSH_THEME.*/OSH_THEME="axin"/g' ~/.bashrc \
    # Helpful aliases to get around the container while debugging
    echo "alias l='ls -la'" >> ~/.bashrc \
    echo "alias s='cd ..'" >> ~/.bashrc \
    # Use bash
    usermod -s /bin/bash root

# Accept incoming HTTP requests
EXPOSE 443

# Supervisor prep
RUN mkdir -p /etc/supervisor/includes /var/log/supervisor
# Main supervisor config
COPY supervisor/supervisord.conf /etc/supervisor
# Supervisor programs
# COPY supervisor/includes/*.conf /etc/supervisor/includes/
# Services start script (and related fixes)
COPY run/start.sh /

# Initialize services (Cron, PHP-FPM and Apache)
CMD bash /start.sh
