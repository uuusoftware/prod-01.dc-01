#!/bin/bash
# NGINX WATCH DAEMON

# shellcheck disable=SC2002
DNS_SERVER=$(cat /etc/resolv.conf | grep -i '^nameserver' | head -n1 | cut -d ' ' -f2)
export DNS_SERVER

template_dir="${NGINX_ENVSUBST_TEMPLATE_DIR:-/etc/nginx/templates}"
suffix="${NGINX_ENVSUBST_TEMPLATE_SUFFIX:-.template}"

function makeChecksum {
  find "$template_dir" -type f -name "*$suffix" -print0 | sort -z | xargs -0 sha1sum | sha1sum | awk '{print $1}'
}

checksum=$(makeChecksum)

# Start nginx
# nginx

while true; do
  sleep 2
  checksum_now=$(makeChecksum)

  if [ "$checksum" != "$checksum_now" ]; then
    echo "[ NGINX ] A configuration TEMPLATE files changed. Run entrypoint"

    rm -rf /etc/nginx/conf.d/*

    RELOAD_ECHO=$(/docker-entrypoint.sh nginx -t && nginx -s reload)

    RELOAD_EXIT_CODE=$?

    if [ $RELOAD_EXIT_CODE -ne 0 ]; then
      echo "Reload failed"
      NGINX_CHECK_CONFIG_MESSAGE=$(nginx -t 2>&1);
      rm -rf /etc/nginx/conf.d/*
      echo "${RELOAD_ECHO}" >/etc/nginx/conf.d/error.log
      echo -e "\n-----------------\n" >>/etc/nginx/conf.d/error.log
      echo "$NGINX_CHECK_CONFIG_MESSAGE"  >>/etc/nginx/conf.d/error.log
      cp /etc/nginx/error.conf /etc/nginx/conf.d/
      nginx -s reload
      echo "Load web error config"
    fi
  fi

  checksum=$checksum_now
done
