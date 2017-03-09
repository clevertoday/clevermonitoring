#!/bin/bash

set -e

function setConfiguration() {
  KEY=$1
  VALUE=$2
  CONFIGURATION_FILE=$3
  sed -i "s/\"$KEY\"/\"$VALUE\"/g" $CONFIGURATION_FILE
}

CONFIGURATION_FILE="/etc/sensu/conf.d/redis.json"
if [ -n "${REDIS_HOST+1}" ]; then
  setConfiguration "localhost" "$REDIS_HOST" $CONFIGURATION_FILE
fi

CONFIGURATION_FILE="/etc/sensu/conf.d/influxdb.json"
if [ -n "${INFLUXDB_HOST+1}" ]; then
  setConfiguration "localhost" "$INFLUXDB_HOST" $CONFIGURATION_FILE
fi

if [ "$1" = "server" ]; then
  exec /opt/sensu/bin/sensu-server -c /etc/sensu/config.json -d /etc/sensu -e /etc/sensu/extensions -v
elif [ "$1" = "api" ]; then
  exec /opt/sensu/bin/sensu-api -c /etc/sensu/config.json -d /etc/sensu -e /etc/sensu/extensions -v
fi

exec "$@"
