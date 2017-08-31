FROM        ikuosu/influxgraph:1.3.7

COPY        graphite-api.yaml       /etc/graphite-api.yaml
COPY        docker-entrypoint.sh    /entrypoint.sh

ENTRYPOINT  ["/entrypoint.sh"]