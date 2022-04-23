BRANCH ?= 1.99.7.2.1
OWNER := wwmoraes
PROJECT := pvpgn-server
MODE ?= plain # plain | mysql | pgsql | sqlite3 | odbc
TAG ?= ${BRANCH}-${MODE}

SHELL := /bin/bash
REPO := ${OWNER}/${PROJECT}

ifeq ($(shell docker buildx inspect --bootstrap | grep Driver | cut -d: -f2 | xargs),docker-container)
BUILDKIT_FLAGS ?= --load
endif

.PHONY: build
build:
	@docker build \
		${BUILDKIT_FLAGS} \
		--build-arg BRANCH=${BRANCH} \
		--build-arg MODE=${MODE} \
		$(if ${TARGET},--target ${TARGET}) \
		-t ${REPO}:${TAG} .

.PHONY: build-develop
build-develop: BRANCH=develop
# build-develop: TAG=develop-${MODE}
build-develop: build

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
