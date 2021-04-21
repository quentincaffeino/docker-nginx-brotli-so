
include .make/common.Makefile


## Nginx versions to build
VERSIONS ?= 


${VERSIONS}:
	$(QUIET) DOCKER_BUILDKIT=${DOCKER_BUILDKIT} docker build --compress \
		--build-arg NGX_BROTLI_MODULE_COMMIT=${NGX_BROTLI_MODULE_COMMIT} \
		--build-arg NGINX_VERSION=$@ \
		--cache-from type=local,src=/tmp/.buildx-cache \
		--cache-to type=local,dest=/tmp/.buildx-cache-new \
		--tag ghcr.io/${USER}/docker-nginx-brotli-so:$@-alpine \
		--file alpine.Dockerfile .
	$(QUIET) DOCKER_BUILDKIT=${DOCKER_BUILDKIT} docker push \
		ghcr.io/${USER}/docker-nginx-brotli-so:$@-alpine

## Build VERSIONS
build:
	$(QUIET) DOCKER_BUILDKIT=${DOCKER_BUILDKIT} docker build --compress \
		--build-arg NGX_BROTLI_MODULE_COMMIT=${NGX_BROTLI_MODULE_COMMIT} \
		--build-arg NGINX_VERSION=$(lastword ${VERSIONS}) \
		--cache-from type=local,src=/tmp/.buildx-cache \
		--cache-to type=local,dest=/tmp/.buildx-cache-new \
		--tag ghcr.io/${USER}/docker-nginx-brotli-so:latest \
		--file alpine.Dockerfile .

	$(QUIET) $(MAKE) -e ${VERSIONS}

	$(QUIET) DOCKER_BUILDKIT=${DOCKER_BUILDKIT} docker push \
		ghcr.io/${USER}/docker-nginx-brotli-so:latest
