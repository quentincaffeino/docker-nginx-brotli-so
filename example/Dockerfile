ARG NGINX_VERSION=1.19.10

FROM ghcr.io/quentincaffeino/nginx-brotli-so:${NGINX_VERSION}-alpine as nginx-brotli-so

# Final target
FROM nginx:${NGINX_VERSION}-alpine

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

COPY --from=nginx-brotli-so /nginx-brotli-so/lib/* /usr/lib/
COPY --from=nginx-brotli-so /nginx-brotli-so/ngx_http_brotli_filter_module.so /etc/nginx/modules/ngx_http_brotli_filter_module.so
COPY --from=nginx-brotli-so /nginx-brotli-so/ngx_http_brotli_static_module.so /etc/nginx/modules/ngx_http_brotli_static_module.so

COPY nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /usr/share/nginx/html/ && \
  echo "<html>Hello world</html>" > /usr/share/nginx/html/index.html
