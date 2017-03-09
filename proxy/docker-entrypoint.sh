#!/bin/bash

set -e

function setConfiguration() {
  KEY=$1
  VALUE=$2
  sed -i "s/{{$KEY}}/$VALUE/g" /etc/nginx/nginx.conf
}


if [ -n "${GRAFANA_HOST+1}" ]; then
  setConfiguration "GRAFANA_HOST" "$GRAFANA_HOST"
else
  setConfiguration "GRAFANA_HOST" "grafana"
fi

if [ -n "${GRAFANA_PORT+1}" ]; then
  setConfiguration "GRAFANA_PORT" "$GRAFANA_PORT"
else
  setConfiguration "GRAFANA_PORT" "3000"
fi


if [ -n "${KIBANA_HOST+1}" ]; then
  setConfiguration "KIBANA_HOST" "$KIBANA_HOST"
else
  setConfiguration "KIBANA_HOST" "kibana"
fi

if [ -n "${KIBANA_PORT+1}" ]; then
  setConfiguration "KIBANA_PORT" "$KIBANA_PORT"
else
  setConfiguration "KIBANA_PORT" "5601"
fi


if [ -n "${GRAPHITE_HOST+1}" ]; then
  setConfiguration "GRAPHITE_HOST" "$GRAPHITE_HOST"
else
  setConfiguration "GRAPHITE_HOST" "graphite"
fi

if [ -n "${GRAPHITE_PORT+1}" ]; then
  setConfiguration "GRAPHITE_PORT" "$GRAPHITE_PORT"
else
  setConfiguration "GRAPHITE_PORT" "80"
fi


if [ -n "${UCHIWA_HOST+1}" ]; then
  setConfiguration "UCHIWA_HOST" "$UCHIWA_HOST"
else 
  setConfiguration "UCHIWA_HOST" "uchiwa"
fi

if [ -n "${UCHIWA_PORT+1}" ]; then
  setConfiguration "UCHIWA_PORT" "$UCHIWA_PORT"
else
  setConfiguration "UCHIWA_PORT" "3000"
fi


if [[ "$1" == -* ]]; then
    set -- /usr/sbin/nginx "$@"
elif [ -z "$1" ]; then
    exec /usr/sbin/nginx
fi


exec "$@"
