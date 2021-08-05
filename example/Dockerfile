ARG NGINX_VERSION=1.20.0

FROM ghcr.io/quentincaffeino/nginx-brotli-so:${NGINX_VERSION}-alpine as nginx-brotli-so

# Final target
FROM nginx:${NGINX_VERSION}-alpine

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

COPY --from=nginx-brotli-so /nginx-brotli-so/lib/* /usr/lib/
COPY --from=nginx-brotli-so /nginx-brotli-so/*.so /etc/nginx/modules/

COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /usr/share/nginx/html/
