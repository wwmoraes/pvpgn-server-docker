TAG ?= latest
OWNER := wwmoraes
PROJECT := $(shell basename $(dir $(abspath $(firstword $(MAKEFILE_LIST)))))

SHELL := /bin/bash
REPO := $(OWNER)/$(PROJECT)

.PHONY: build
build:
	@docker build -t $(REPO):latest .

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
	@docker run --rm -it $(REPO):$(TAG)

.PHONY: sh
sh:
	@docker run --rm -it $(REPO):$(TAG) /bin/ash
