FROM 				clevertodayinc/clever-nginx:22
MAINTAINER 	Brice Argenson <brice@clevertoday.com>

COPY        docker-entrypoint.sh  /entrypoint.sh

COPY				html  /usr/share/nginx/html
COPY 			  tls   /etc/nginx/tls
COPY 				config/nginx.conf  /etc/nginx/nginx.conf

EXPOSE 			80 443

ENTRYPOINT  ["/entrypoint.sh"]
