
include .make/common.Makefile


## Nginx versions to build
VERSIONS ?= 


${VERSIONS}:
	$(QUIET) DOCKER_BUILDKIT=${DOCKER_BUILDKIT} docker build --compress \
		--build-arg NGX_BROTLI_MODULE_COMMIT=${NGX_BROTLI_MODULE_COMMIT} \
		--build-arg NGINX_VERSION=$@ \
		-t ghcr.io/${USER}/docker-nginx-brotli-so:$@-alpine \
		--file alpine.Dockerfile .
	$(QUIET) DOCKER_BUILDKIT=${DOCKER_BUILDKIT} docker push \
		ghcr.io/${USER}/docker-nginx-brotli-so:$@-alpine

## Build VERSIONS
build:
	$(QUIET) $(MAKE) -e ${VERSIONS}
