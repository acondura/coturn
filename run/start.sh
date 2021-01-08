#!/usr/bin/env bash

### Permissions fix for local dev
# Apache uid and gid must have the same values as the host user,
# otherwise bind mount for /var/www/html runs into permissions issues.
# Change apache uid only if env var is set
if [[ ! -z "$HOST_USR" ]]; then 
  usermod -u $HOST_USR apache
fi
# Change apache gid only if env var is set
if [[ ! -z "$HOST_GRP" ]]; then 
  groupmod -g $HOST_GRP apache
fi
##########################################

### Local bash distro
if [ ! -z "$USE_LOCAL" ] && [ "$USE_LOCAL" == "enabled" ]; then
  cd /root/ && bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
  # Use a theme that clearly shows user, path and git branch
  sed -i 's/OSH_THEME.*/OSH_THEME="axin"/g' /root/.bashrc
  # Helpful aliases to get around the container while debugging
  echo "alias l='ls -la'" >> /root/.bashrc
  echo "alias s='cd ..'" >> /root/.bashrc
  # Use bash
  usermod -s /bin/bash root

  # Same bash distro for apache user
  cp -rf /root/.bashrc /var/www
  sed -i 's/export OSH=\/root/export OSH=\/var\/www/g' /var/www/.bashrc
  cp -rf /root/.oh-my-bash /var/www
  cp -rf /root/.osh-update /var/www
  chown -R apache:apache /var/www/.bashrc /var/www/.oh-my-bash /var/www/.osh-update
  # Use bash
  usermod -s /bin/bash apache
fi

# Fix ownership
chown -R apache:apache /var/log /var/www /run/apache2

# Start services
supervisord -c /etc/supervisor/supervisord.conf -j /var/run/supervisord.pid