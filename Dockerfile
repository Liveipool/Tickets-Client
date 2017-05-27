FROM node:6.10.3

ENV NGINX_VERSION 1.13.0-1~jessie
ENV NJS_VERSION   1.13.0.0.1.10-1~jessie

COPY ./nginx_signing.key .
RUN apt-key add nginx_signing.key \
    && echo "deb http://nginx.org/packages/mainline/debian/ jessie nginx" >> /etc/apt/sources.list \
    && apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y \
                        nginx=${NGINX_VERSION} \
                        nginx-module-xslt=${NGINX_VERSION} \
                        nginx-module-geoip=${NGINX_VERSION} \
                        nginx-module-image-filter=${NGINX_VERSION} \
                        nginx-module-njs=${NJS_VERSION} \
                        gettext-base \
    && rm -rf /var/lib/apt/lists/*

# Forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

STOPSIGNAL SIGQUIT

WORKDIR /static-server

COPY ./package.json .
RUN npm install && npm install gulp -g

COPY ./nginx.conf /etc/nginx/nginx.conf

COPY . .
RUN gulp build

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
