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

Yet another [pvpgn-docker](https://github.com/search?q=pvpgn-docker) project.
Aims to be:

- ⌛ time-proof - builds binaries directly from [source][pvpgn-server]
- 🔐 secure - uses non-privileged user and group to run the server
- 🗜 small - based on Alpine linux
- ⚖ lightweight - final image doesn't contain source or build tools

[pvpgn-server]: https://github.com/pvpgn/pvpgn-server

## 🏁 Getting Started <a name = "getting_started"></a>

Pull the image from Docker Hub:

```sh
docker pull wwmoraes/pvpgn-server
```

Then/or just run:

```sh
docker run -it wwmoraes/pvpgn-server
```

PvPGN-PRO is built and installed on the root filesystem. A sample configuration
can be found at `/etc/pvpgn`. Data (logs, storage, scripts, etc) can be found
at `/var/pvpgn`. These are the default locations `bnetd` will use, unless you
configure it to use distinct paths.

## 🚀 Deployment <a name = "deployment"></a>

The configuration and data paths should be bound to volumes for persistence, and
the ports should be published so you can access the server outside of the
container:

```sh
docker run -it -p 6112:6112 -p 4000:4000 \
  -v <your-config-volume-or-path>:/etc/pvpgn \
  -v <your-data-volume-or-path>:/var/pvpgn \
  wwmoraes/pvpgn-server
```

**IMPORTANT**: Make sure the volumes/bind mount sources are readable and
writable by the server user and group. The image default is 1001.

## 🎈 Usage <a name="usage"></a>

The build is done with Lua script support enabled, and MySQL support for the
account backend.

You can create persistent local volumes for the config and data without starting
the server with:

```sh
docker run --rm --entrypoint=true \
  -v <your-config-volume-name>:/etc/pvpgn \
  -v <your-data-volume-name>:/var/pvpgn \
  wwmoraes/pvpgn-server
```

Both volumes must not exist prior to this call for Docker to create and populate
them with the image contents.

You can also copy the files to your host system using a temporary bind mount,
for instance:

```sh
mkdir {var,etc}

docker run --rm --entrypoint=cp --user "$(id -u):$(id -g)" \
  -v $PWD/var:/mnt/var \
  wwmoraes/pvpgn-server \
  -r /var/pvpgn /mnt/var

docker run --rm --entrypoint=cp --user "$(id -u):$(id -g)" \
  -v $PWD/etc:/mnt/etc \
  wwmoraes/pvpgn-server \
  -r /etc/pvpgn /mnt/etc
```

Please refer to the upstream documentation on how to configure your server.

- [PvPGN Configuration](https://pvpgn.pro/pvpgn_installation.html)
- [D2GS Installation Guide](https://pvpgn.pro/d2gs_installation.html)

## 🎉 Acknowledgements <a name = "acknowledgement"></a>

- [PvPGN-PRO](https://github.com/pvpgn/pvpgn-server) and its maintainers, which are keeping alive the legacy of PvPGN
- [@ibepeer](https://github.com/ibepeer) for feedback on #3, which ended on a BRANCH build arg (to clone from develop, for instance)
