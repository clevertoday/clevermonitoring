FROM        node:7.7

RUN         apt-get update && apt-get install -y curl unzip fontconfig && \
            rm -rf /var/lib/apt/lists/*

RUN         npm install -g phantomjs@1.9.20 && \
            curl -O http://yslow.org/yslow-phantomjs-3.1.8.zip && \
            unzip yslow-phantomjs-3.1.8.zip -d /yslow && \
            rm yslow-phantomjs-3.1.8.zip

COPY        src   /server

ENTRYPOINT  ["/server/server.js"]