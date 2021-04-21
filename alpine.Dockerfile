ARG NGINX_VERSION=1.19.10

FROM curlimages/curl:7.76.1 as download-ngx_brotli

WORKDIR /tmp

ARG NGX_BROTLI_MODULE_COMMIT=9aec15e2aa6feea2113119ba06460af70ab3ea62

RUN curl -OLC - "https://github.com/google/ngx_brotli/archive/${NGX_BROTLI_MODULE_COMMIT}.tar.gz" \
  && ls -al /tmp


# Target which builds brotli extension for nginx
# @see https://github.com/lunatic-cat/docker-nginx-brotli
FROM nginx:${NGINX_VERSION}-alpine as docker-nginx-brotli-so-build

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

WORKDIR /docker-nginx-brotli-so-build

# For latest build deps, see https://github.com/nginxinc/docker-nginx/blob/master/mainline/alpine/Dockerfile
RUN apk add --no-cache --virtual .build-deps \
  gcc \
  libc-dev \
  make \
  openssl-dev \
  pcre-dev \
  zlib-dev \
  linux-headers \
  libxslt-dev \
  gd-dev \
  geoip-dev \
  perl-dev \
  libedit-dev \
  mercurial \
  bash \
  alpine-sdk \
  findutils

RUN apk add --no-cache --virtual .brotli-dev \
  brotli-dev

ARG NGINX_VERSION

RUN curl -OLC - "https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" > "nginx-${NGINX_VERSION}.tar.gz"

ARG NGX_BROTLI_MODULE_COMMIT

COPY --from=download-ngx_brotli \
  "/tmp/${NGX_BROTLI_MODULE_COMMIT}.tar.gz" \
  "./ngx_brotli-${NGX_BROTLI_MODULE_COMMIT}.tar.gz"

# Reuse same cli arguments as the nginx:alpine image used to build
RUN CONFARGS=$(nginx -V 2>&1 | sed -n -e 's/^.*arguments: //p') \
  tar -zxf "nginx-${NGINX_VERSION}.tar.gz" && \
  tar -xzf "ngx_brotli-${NGX_BROTLI_MODULE_COMMIT}.tar.gz"

WORKDIR /docker-nginx-brotli-so-build/nginx-${NGINX_VERSION}

RUN ./configure --with-compat $CONFARGS --add-dynamic-module="$(pwd)/../ngx_brotli-${NGX_BROTLI_MODULE_COMMIT}" && \
  make && make install

# save /usr/lib/*so deps
RUN mkdir -p /so-deps/lib && \
  cp -L $(ldd /usr/local/nginx/modules/ngx_http_brotli_filter_module.so 2>/dev/null | grep '/usr/lib/' | awk '{ print $3 }' | tr '\n' ' ') /so-deps/lib

FROM scratch

COPY --from=docker-nginx-brotli-so-build \
  /so-deps \
  /usr/local/nginx/modules/ngx_http_brotli_filter_module.so \
  /usr/local/nginx/modules/ngx_http_brotli_static_module.so \
  /docker-nginx-brotli-so/
