.PHONY: build
build: src
	@docker build -t pvpgn-server:latest .

.PHONY: src
src:
	@if [ ! -d pvpgn-server ]; then git clone https://github.com/pvpgn/pvpgn-server.git; fi

.PHONY: ls
ls:
	@docker create --name="pvpgn-server_latest_ls" pvpgn-server:latest > /dev/null
	@docker export pvpgn-server_latest_ls | tar t
	@docker container rm pvpgn-server_latest_ls > /dev/null

.PHONY: export
export:
	@docker create --name="pvpgn-server_latest_export" pvpgn-server:latest > /dev/null
	@docker export pvpgn-server_latest_export > pvpgn-server-latest.tar
	@docker container rm pvpgn-server_latest_export > /dev/null

.PHONY: run
run:
	@docker run --rm -it pvpgn-server:latest

.PHONY: sh
sh:
	@docker run --rm -it pvpgn-server:latest /bin/ash
