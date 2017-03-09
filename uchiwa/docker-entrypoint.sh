#!/bin/sh

set -e

setConfiguration () {
  KEY=$1
  VALUE=$2
  CONFIGURATION_FILE=$3
  sed -i "s/\"$KEY\"/\"$VALUE\"/g" $CONFIGURATION_FILE
}

CONFIGURATION_FILE="/config/config.json"
if [ -n "${SENSU_HOST+1}" ]; then
  setConfiguration "localhost" "$SENSU_HOST" $CONFIGURATION_FILE
fi

if [ "$1" = "start" ]; then
  exec /go/bin/uchiwa -c /config/config.json
fi

exec "$@"
