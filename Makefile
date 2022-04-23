BRANCH ?= develop
OWNER := wwmoraes
PROJECT := pvpgn-server
MODE ?= plain # plain | mysql | pgsql | sqlite3 | odbc
TAG ?= ${BRANCH}-${MODE}

SHELL := /bin/bash
REPO := ${OWNER}/${PROJECT}

GIT_REV = $(shell git log -n 1 --format="%H")
DATE = $(shell date -u +"%Y-%m-%dT%TZ")

ifeq ($(shell docker buildx inspect --bootstrap | grep Driver | cut -d: -f2 | xargs),docker-container)
BUILDKIT_FLAGS ?= --load
endif

.PHONY: build-all
build-all: build-plain build-mysql build-pgsql build-sqlite3 build-odbc

build-%: MODE=%
build-%: build

.PHONY: build
build:
	@docker build \
		${BUILDKIT_FLAGS} \
		--build-arg BRANCH=${BRANCH} \
		--build-arg MODE=${MODE} \
		$(if ${TARGET},--target ${TARGET}) \
		-t ${REPO}:${TAG} .

.PHONY: release-all
release-all: release-plain release-mysql release-pgsql release-sqlite3 release-odbc

release-%: MODE=%
release-%: release

.PHONY: release
release:
	@docker build --push \
		--platform linux/amd64,linux/arm/v7,linux/arm64 \
		--label org.opencontainers.image.title="PvPGN-PRO" \
		--label org.opencontainers.image.description="Next generation of PvPGN server" \
		--label org.opencontainers.image.url=https://github.com/wwmoraes/pvpgn-server-docker \
  	--label org.opencontainers.image.source=https://github.com/wwmoraes/pvpgn-server-docker \
		--label org.opencontainers.image.created=${DATE} \
  	--label org.opencontainers.image.revision=${GIT_REV} \
  	--label org.opencontainers.image.licenses=Apache-2.0 \
		--label org.opencontainers.image.version=${BRANCH} \
		--label org.opencontainers.image.documentation=https://pvpgn.pro \
		--build-arg BRANCH=${BRANCH} \
		--build-arg MODE=${MODE} \
		-t ${REPO}:${TAG} \
		-t ${REPO}:latest-${MODE} \
		.

.PHONY: ls
ls:
	@docker create --name="${PROJECT}_${TAG}_ls" ${REPO}:${TAG} > /dev/null
	@docker export ${PROJECT}_${TAG}_ls | tar t
	@docker container rm ${PROJECT}_${TAG}_ls > /dev/null

.PHONY: export
export:
	@docker create --name="${PROJECT}_${TAG}_export" ${REPO}:${TAG} > /dev/null
	@docker export ${PROJECT}_${TAG}_export > ${PROJECT}-${TAG}.tar
	@docker container rm ${PROJECT}_${TAG}_export > /dev/null

.PHONY: run
run:
	@docker run --rm -p 4000:4000 -p 6112:6112 -it ${REPO}:${TAG}

.PHONY: sh
sh:
	@docker run --rm -it --entrypoint=ash ${REPO}:${TAG}
