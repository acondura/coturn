#!/usr/bin/env bash

### Local bash distro
if [ ! -z "$USE_OHMYBASH" ] && [ "$USE_OHMYBASH" == "enabled" ]; then
  cd /root/ && bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
  # Use a theme that clearly shows user, path and git branch
  sed -i 's/OSH_THEME.*/OSH_THEME="axin"/g' /root/.bashrc
  # Helpful aliases to get around the container while debugging
  echo "alias l='ls -la'" >> /root/.bashrc
  echo "alias s='cd ..'" >> /root/.bashrc
  # Use bash
  usermod -s /bin/bash root
fi

# Start services
supervisord -c /etc/supervisor/supervisord.conf -j /var/run/supervisord.pid