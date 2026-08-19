#!/bin/sh
set -e

nginx -g "daemon off;" &
NGINX_PID=$!

sleep 2

if curl -s http://localhost:8080/stub_status > /dev/null; then
    echo "Nginx metrics endpoint is available"
else
    echo "Warning: Nginx metrics endpoint is not available"
fi

wait $NGINX_PID