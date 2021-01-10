#!/usr/bin/env bash

# Start services
supervisord -c /etc/supervisor/supervisord.conf -j /var/run/supervisord.pid