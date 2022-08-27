
include .make/common.Makefile


## Nginx versions to build
VERSIONS ?= 

## Platforms to build
PLATFORMS ?= 


${VERSIONS}:
	$(QUIET) DOCKER_BUILDKIT=${DOCKER_BUILDKIT} docker buildx build \
		--build-arg NGX_BROTLI_MODULE_COMMIT=${NGX_BROTLI_MODULE_COMMIT} \
		--build-arg NGINX_VERSION=$@ \
		--compress \
		--cache-from type=local,src=/tmp/.buildx-cache/$@ \
		--cache-to type=local,dest=/tmp/.buildx-cache-new/$@ \
		--platform=${PLATFORMS} \
		--push \
		--tag ghcr.io/${USER}/nginx-brotli-so:$@-alpine \
		--file alpine.Dockerfile .

## Build all VERSIONS
build:
	$(QUIET) $(MAKE) -e ${VERSIONS}
