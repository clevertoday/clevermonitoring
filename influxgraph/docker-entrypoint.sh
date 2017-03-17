#!/bin/bash

set -e

if [ -n "${INFLUXDB_HOST+1}" ]; then
  sed -i "s/{{INFLUXDB_HOST}}/$INFLUXDB_HOST/g" /etc/graphite-api.yaml
else
  echo "INFLUXDB_HOST environment variable is not defined"
  exit 2
fi

exec /sbin/my_init