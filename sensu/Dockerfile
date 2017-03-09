FROM        ubuntu:16.04
MAINTAINER  Brice Argenson <brice@clevertoday.com>

ENV         SENSU_CONFIG  /etc/sensu

RUN         apt-get -y update && apt-get install -y apt-transport-https wget && \
            wget -q https://sensu.global.ssl.fastly.net/apt/pubkey.gpg -O- | apt-key add - && \
            echo "deb     https://sensu.global.ssl.fastly.net/apt sensu main" > /etc/apt/sources.list.d/sensu.list && \
            apt-get -y update && apt-get install -y sensu

RUN         apt-get -y update && apt-get install -y ruby ruby-dev build-essential && \
            gem install mail --no-ri --no-rdoc && \
            gem install json --no-ri --no-rdoc && \
            gem install sensu-plugin --no-ri --no-rdoc && \
            gem install em-http-request --no-ri --no-rdoc

COPY        config  $SENSU_CONFIG/conf.d
COPY        extensions  $SENSU_CONFIG/extensions
COPY        handlers  $SENSU_CONFIG/handlers

COPY        docker-entrypoint.sh  /entrypoint.sh

ENTRYPOINT  ["/entrypoint.sh"]
