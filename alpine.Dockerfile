ARG NGINX_VERSION=1.19.10
ARG NGX_BROTLI_MODULE_COMMIT=9aec15e2aa6feea2113119ba06460af70ab3ea62


FROM alpine:3.18 as download-ngx_brotli

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

ARG NGX_BROTLI_MODULE_COMMIT

RUN apk add --no-cache curl && \
  curl -OLC - "https://github.com/google/ngx_brotli/archive/${NGX_BROTLI_MODULE_COMMIT}.tar.gz" > "${NGX_BROTLI_MODULE_COMMIT}.tar.gz"


# Target which builds brotli extension for nginx
# @see https://github.com/lunatic-cat/docker-nginx-brotli
FROM nginx:${NGINX_VERSION}-alpine as nginx-brotli-so-build

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

WORKDIR /nginx-brotli-so-build

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
  "/${NGX_BROTLI_MODULE_COMMIT}.tar.gz" \
  "./ngx_brotli-${NGX_BROTLI_MODULE_COMMIT}.tar.gz"

RUN gzip -d "./nginx-${NGINX_VERSION}.tar.gz" && \
  tar xvf "./nginx-${NGINX_VERSION}.tar"

RUN gzip -d "./ngx_brotli-${NGX_BROTLI_MODULE_COMMIT}.tar.gz" && \
  tar xvf "./ngx_brotli-${NGX_BROTLI_MODULE_COMMIT}.tar"

# Reuse same cli arguments as the nginx:alpine image used to build
RUN CONFARGS=$(nginx -V 2>&1 | sed -n -e 's/^.*arguments: //p')

WORKDIR /nginx-brotli-so-build/nginx-${NGINX_VERSION}

RUN ./configure --with-compat $CONFARGS --add-dynamic-module="$(pwd)/../ngx_brotli-${NGX_BROTLI_MODULE_COMMIT}" && \
  make && make install

# save /usr/lib/*so deps
RUN mkdir -p /so-deps/lib && \
  cp -L $(ldd /usr/local/nginx/modules/ngx_http_brotli_filter_module.so 2>/dev/null | grep '/usr/lib/' | awk '{ print $3 }' | tr '\n' ' ') /so-deps/lib


# Final image with just SOs
FROM scratch

COPY --from=nginx-brotli-so-build \
  /so-deps \
  /usr/local/nginx/modules/ngx_http_brotli_filter_module.so \
  /usr/local/nginx/modules/ngx_http_brotli_static_module.so \
  /nginx-brotli-so/
