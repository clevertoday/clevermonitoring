#!/bin/bash

set -e

function setConfiguration() {
  KEY=$1
  VALUE=$2
  CONFIGURATION_FILE=$3
  sed -i "s/\"$KEY\"/\"$VALUE\"/g" $CONFIGURATION_FILE
}

export PATH=$PATH:/etc/sensu/plugins:/etc/sensu/handlers:/etc/sensu/extensions

CONFIGURATION_FILE="/etc/sensu/conf.d/redis.json"
if [ -n "${REDIS_HOST+1}" ]; then
  setConfiguration "localhost" "$REDIS_HOST" $CONFIGURATION_FILE
fi

CONFIGURATION_FILE="/etc/sensu/conf.d/handlers.json"
if [ -n "${INFLUXDB_HOST+1}" ]; then
  setConfiguration "localhost" "$INFLUXDB_HOST" $CONFIGURATION_FILE
fi

if [ -d "/conf.d" ]; then
  rsync -avh --progress /conf.d $SENSU_CONFIG
fi

if [ -d "/plugins" ]; then
  rsync -avh --progress /plugins $SENSU_CONFIG
fi

if [ -d "/handlers" ]; then
  rsync -avh --progress /handlers $SENSU_CONFIG
fi

if [ "$1" = "server" ]; then
  exec /opt/sensu/bin/sensu-server -c /etc/sensu/config.json -d /etc/sensu -e /etc/sensu/extensions -v
elif [ "$1" = "api" ]; then
  exec /opt/sensu/bin/sensu-api -c /etc/sensu/config.json -d /etc/sensu -e /etc/sensu/extensions -v
elif [ "$1" = "client" ]; then
  exec /opt/sensu/bin/sensu-client -c /etc/sensu/config.json -d /etc/sensu -e /etc/sensu/extensions -v
fi

exec "$@"
