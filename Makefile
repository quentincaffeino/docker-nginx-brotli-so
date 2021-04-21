
include .make/common.Makefile


## Nginx versions to build
VERSIONS ?= 


${VERSIONS}:
	$(QUIET) DOCKER_BUILDKIT=${DOCKER_BUILDKIT} docker build --compress \
		--build-arg NGX_BROTLI_MODULE_COMMIT=${NGX_BROTLI_MODULE_COMMIT} \
		--build-arg NGINX_VERSION=$@ \
		-t ghcr.io/${USER}/docker-nginx-brotli-so:$@-alpine \
		--file alpine.Dockerfile .

## Build VERSIONS
build:
	$(QUIET) $(MAKE) -e ${VERSIONS}
	$(QUIET) DOCKER_BUILDKIT=${DOCKER_BUILDKIT} docker push -a \
		ghcr.io/${USER}/docker-nginx-brotli-so