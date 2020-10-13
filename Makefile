TAG ?= latest
OWNER := wwmoraes
PROJECT := $(shell basename $(dir $(abspath $(firstword $(MAKEFILE_LIST)))))

SHELL := /bin/bash
REPO := $(OWNER)/$(PROJECT)

.PHONY: build
build:
	@docker build -t $(REPO):$(TAG) .

.PHONY: build-develop
build:
	@docker build --build-arg BRANCH=develop -t $(REPO):$(TAG) .

.PHONY: ls
ls:
	@docker create --name="$(PROJECT)_$(TAG)_ls" $(REPO):$(TAG) > /dev/null
	@docker export $(PROJECT)_$(TAG)_ls | tar t
	@docker container rm $(PROJECT)_$(TAG)_ls > /dev/null

.PHONY: export
export:
	@docker create --name="$(PROJECT)_$(TAG)_export" $(REPO):$(TAG) > /dev/null
	@docker export $(PROJECT)_$(TAG)_export > $(PROJECT)-$(TAG).tar
	@docker container rm $(PROJECT)_$(TAG)_export > /dev/null

.PHONY: run
run:
	@docker run --rm -p 4000:4000 -p 6112:6112 -it $(REPO):$(TAG)

.PHONY: sh
sh:
	@docker run --rm -it $(REPO):$(TAG) /bin/ash
