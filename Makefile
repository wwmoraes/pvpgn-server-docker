.DEFAULT_GOAL := build

.PHONY: buildx
buildx:
	@docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7,linux/arm/v6 -t wwmoraes/pvpgn-server:latest .

.PHONY: inspect
inspect:
	@docker buildx imagetools inspect wwmoraes/pvpgn-server:latest

.PHONY: build
build:
	@docker build -t wwmoraes/pvpgn-server:latest .

.PHONY: ls
ls:
	@docker create --name="pvpgn-server_latest_ls" wwmoraes/pvpgn-server:latest > /dev/null
	@docker export wwmoraes/pvpgn-server_latest_ls | tar t
	@docker container rm wwmoraes/pvpgn-server_latest_ls > /dev/null

.PHONY: export
export:
	@docker create --name="pvpgn-server_latest_export" wwmoraes/pvpgn-server:latest > /dev/null
	@docker export wwmoraes/pvpgn-server_latest_export > wwmoraes/pvpgn-server-latest.tar
	@docker container rm wwmoraes/pvpgn-server_latest_export > /dev/null

.PHONY: run
run:
	@docker run --rm -it wwmoraes/pvpgn-server:latest

.PHONY: sh
sh:
	@docker run --rm -it wwmoraes/pvpgn-server:latest /bin/ash
