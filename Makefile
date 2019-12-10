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
