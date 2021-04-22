
include .make/common.Makefile


## Nginx versions to build
VERSIONS ?= 


${VERSIONS}:
	$(QUIET) DOCKER_BUILDKIT=${DOCKER_BUILDKIT} docker build \
		--build-arg NGX_BROTLI_MODULE_COMMIT=${NGX_BROTLI_MODULE_COMMIT} \
		--build-arg NGINX_VERSION=$@ \
		--compress \
		--cache-from type=local,src=/tmp/.buildx-cache \
		--cache-to type=local,dest=/tmp/.buildx-cache-new \
		--push \
		--tag ghcr.io/${USER}/nginx-brotli-so:$@-alpine \
		--file alpine.Dockerfile .

## Build VERSIONS
build:
	$(QUIET) $(MAKE) -e ${VERSIONS}
