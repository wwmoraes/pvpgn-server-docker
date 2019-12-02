<div align="center">

  ![PvPGN-PRO Docker](https://i.imgur.com/QfNbRxi.png)

### PvPGN Server Docker

![Status](https://img.shields.io/badge/status-active-success.svg)
[![GitHub Issues](https://img.shields.io/github/issues/wwmoraes/pvpgn-server-docker.svg)](https://github.com/wwmoraes/pvpgn-server-docker/issues)
[![GitHub Pull Requests](https://img.shields.io/github/issues-pr/wwmoraes/pvpgn-server-docker.svg)](https://github.com/wwmoraes/pvpgn-server-docker/pulls)
[![License](https://img.shields.io/badge/license-AL2-blue.svg)](/LICENSE)

</div>

---

> A simple docker and docker-compose for running a PvPGN-PRO server in no time

## 📝 Table of Contents

- [About](#about)
- [Getting Started](#getting_started)
- [Deployment](#deployment)
- [Usage](#usage)
- [Built Using](#built_using)
- [TODO](https://github.com/wwmoraes/pvpgn-server-docker/blob/master/TODO.md)
- [Contributing](https://github.com/wwmoraes/pvpgn-server-docker/blob/master/CONTRIBUTING.md)
- [Acknowledgments](#acknowledgement)

## 🧐 About <a name = "about"></a>

Yet another [pvpgn-docker](https://github.com/search?q=pvpgn-docker) project. Aims to be:

- ⌛ time-proof, by pulling the latest code from PvPGN-PRO repo
- 🔐 secure, by using non-privileged user and group to run the server
- 🗜 small, by using alpine linux instead of ubuntu
- ⚖ lightweight, by using multi-target building to keep only the needed content on the final image

## 🏁 Getting Started <a name = "getting_started"></a>

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See [deployment](#deployment) for notes on how to deploy the project on a live system.

### Prerequisites

You'll need docker at least [docker](https://docs.docker.com/install/) to run the base image, and [docker-compose](https://docs.docker.com/compose/install/) to run the full-blown server.

### Installing

Pull the image from Docker Hub:

```sh
docker pull wwmoraes/pvpgn-server
```

Then run:
```sh
docker run --rm -it pvpgn-server:latest # or make run
```

## 🎈 Usage <a name="usage"></a>

The image exposes the ports 6112 (Battle.net server) and 4000 (game server). You should be able to connect your game through the host IP.

For detailed info about it read through the [PvPGN-PRO](https://pvpgn.pro/) docs:

- [PvPGN Configuration](https://pvpgn.pro/pvpgn_installation.html)
- [D2GS Installation Guide](https://pvpgn.pro/d2gs_installation.html)

## 🎉 Acknowledgements <a name = "acknowledgement"></a>

- [PvPGN-PRO](https://github.com/pvpgn/pvpgn-server) and its maintainers, which are keeping alive the legacy of PvPGN
