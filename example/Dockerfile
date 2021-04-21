ARG NGINX_VERSION=1.19.10

FROM ghcr.io/quentincaffeino/docker-nginx-brotli-so:${NGINX_VERSION}-alpine as docker-nginx-brotli-so

# Final target
FROM nginx:${NGINX_VERSION}-alpine

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

COPY --from=docker-nginx-brotli-so /docker-nginx-brotli-so/lib/* /usr/lib/
COPY --from=docker-nginx-brotli-so /docker-nginx-brotli-so/ngx_http_brotli_filter_module.so /etc/nginx/modules/ngx_http_brotli_filter_module.so
COPY --from=docker-nginx-brotli-so /docker-nginx-brotli-so/ngx_http_brotli_static_module.so /etc/nginx/modules/ngx_http_brotli_static_module.so

COPY nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /usr/share/nginx/html/ && \
  echo "<html>Hello world</html>" > /usr/share/nginx/html/index.html
