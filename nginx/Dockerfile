ARG VERSION=1.23.4-alpine
FROM nginx:${VERSION}

# nginx:alpine contains NGINX_VERSION environment variable, like so:
# ENV NGINX_VERSION 1.15.0

ENV NGINX_ENVSUBST_TEMPLATE_DIR=/data/main/nginx-templates
ENV NGINX_ENVSUBST_TEMPLATE_SUFFIX=.nginx

# Additional module version
ENV PROXY_CONNECT_VERSION 102101

ENV BROTLI_VERSION "v1.0.0rc"

# For latest build deps, see https://github.com/nginxinc/docker-nginx/blob/master/mainline/alpine/Dockerfile
RUN apk add --no-cache --virtual .build-deps \
  git \
  gcc \
  libc-dev \
  make \
  openssl-dev \
  pcre2-dev \
  zlib-dev \
  linux-headers \
  libxslt-dev \
  gd-dev \
  geoip-dev \
  libedit-dev \
  bash \
  alpine-sdk \
  findutils

# Download sources
RUN wget "https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" -O nginx.tar.gz
# RUN git clone https://github.com/chobits/ngx_http_proxy_connect_module.git
RUN git clone https://github.com/yaoweibin/ngx_http_substitutions_filter_module.git
RUN git clone https://github.com/google/ngx_brotli.git && \
    cd ./ngx_brotli && \
    git submodule update --init && \
    cd ../
RUN git clone https://github.com/giom/nginx_accept_language_module

# Reuse same cli arguments as the nginx:alpine image used to build (but remove the erroneous -fomit-frame-pointer)
RUN CONFARGS=$(nginx -V 2>&1 | sed -n -e 's/^.*arguments: //p') && \
    CONFARGS=${CONFARGS/-Os -fomit-frame-pointer -g/-Os} && \
    mkdir -p /usr/src && \
    tar -zxC /usr/src -f nginx.tar.gz && \
    cd /usr/src/nginx-$NGINX_VERSION && \
    # patch -p1 < /ngx_http_proxy_connect_module/patch/proxy_connect_rewrite_${PROXY_CONNECT_VERSION}.patch && \
    ./configure  \
    --with-compat $CONFARGS  \
    # --add-dynamic-module=/ngx_http_proxy_connect_module  \
    --add-module=/ngx_http_substitutions_filter_module \
    --add-module=/ngx_brotli \
    --add-module=/nginx_accept_language_module \
    --with-http_sub_module \
    --with-http_gzip_static_module \
    && \
    make && make install

RUN apk add --no-cache bash

COPY nginx.conf /etc/nginx/templates/default.conf.template
COPY error.conf /etc/nginx/error.conf

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

COPY watch-templates-daemon.sh /
RUN chmod +x /watch-templates-daemon.sh

EXPOSE 8080

STOPSIGNAL SIGTERM

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
