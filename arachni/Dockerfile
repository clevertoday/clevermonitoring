FROM          node:7.7
MAINTAINER    Grégoire Weber <gregoire@clevertoday.com>

ENV           NODE_ENV=production

RUN           curl -L -o arachni.tar.gz https://github.com/Arachni/arachni/releases/download/v1.5/arachni-1.5-0.5.11-linux-x86_64.tar.gz > /dev/null && \
              tar -xvf /arachni.tar.gz && \
              rm -rf /arachni.tar.gz && \
              mkdir server && \
              mkdir reports

COPY          src /server

RUN           cd /server/ && npm install

ENTRYPOINT    ["/server/index.js"]