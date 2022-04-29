ARG MODE=mysql
FROM alpine:latest AS build-base

### Install build dependencies
RUN apk --quiet --no-cache add \
  git \
  build-base \
  clang \
  cmake \
  make \
  zlib-dev \
  curl-dev \
  lua-dev \
  && rm -rf /var/cache/apk/* \
  ;

### CMake & make
ARG REPO=https://github.com/pvpgn/pvpgn-server.git
ARG BRANCH=master
RUN git clone --depth 1 --single-branch --branch ${BRANCH} ${REPO} /src

RUN mkdir /src/build /usr/local/pvpgn
WORKDIR /src

ENV WITH_LUA=true
ENV WITH_MYSQL=false
ENV WITH_SQLITE3=false
ENV WITH_PGSQL=false
ENV WITH_ODBC=false

################################################################################
FROM build-base AS build-plain

RUN cmake -G "Unix Makefiles" -H./ -B./build \
  -D WITH_LUA=${WITH_LUA} \
  -D WITH_MYSQL=${WITH_MYSQL} \
  -D WITH_SQLITE3=${WITH_SQLITE3} \
  -D WITH_PGSQL=${WITH_PGSQL} \
  -D WITH_ODBC=${WITH_ODBC} \
  -D CMAKE_INSTALL_PREFIX=/ \
  ../ && cd build && make

################################################################################
FROM build-base AS build-mysql

RUN apk --quiet --no-cache add \
  mariadb-dev \
  && rm -rf /var/cache/apk/* \
  ;

ENV WITH_MYSQL=true

RUN cmake -G "Unix Makefiles" -H./ -B./build \
  -D WITH_LUA=${WITH_LUA} \
  -D WITH_MYSQL=${WITH_MYSQL} \
  -D WITH_SQLITE3=${WITH_SQLITE3} \
  -D WITH_PGSQL=${WITH_PGSQL} \
  -D WITH_ODBC=${WITH_ODBC} \
  -D CMAKE_INSTALL_PREFIX=/ \
  ../ && cd build && make

################################################################################
FROM build-base AS build-pgsql

RUN apk --quiet --no-cache add \
  libpq-dev \
  && rm -rf /var/cache/apk/* \
  ;

ENV WITH_PGSQL=true

RUN cmake -G "Unix Makefiles" -H./ -B./build \
  -D WITH_LUA=${WITH_LUA} \
  -D WITH_MYSQL=${WITH_MYSQL} \
  -D WITH_SQLITE3=${WITH_SQLITE3} \
  -D WITH_PGSQL=${WITH_PGSQL} \
  -D WITH_ODBC=${WITH_ODBC} \
  -D CMAKE_INSTALL_PREFIX=/ \
  ../ && cd build && make

################################################################################
FROM build-base AS build-sqlite3

RUN apk --quiet --no-cache add \
  sqlite-dev \
  && rm -rf /var/cache/apk/* \
  ;

ENV WITH_SQLITE3=true

RUN cmake -G "Unix Makefiles" -H./ -B./build \
  -D WITH_LUA=${WITH_LUA} \
  -D WITH_MYSQL=${WITH_MYSQL} \
  -D WITH_SQLITE3=${WITH_SQLITE3} \
  -D WITH_PGSQL=${WITH_PGSQL} \
  -D WITH_ODBC=${WITH_ODBC} \
  -D CMAKE_INSTALL_PREFIX=/ \
  ../ && cd build && make

################################################################################
FROM build-base AS build-odbc

RUN apk --quiet --no-cache add \
  unixodbc-dev \
  && rm -rf /var/cache/apk/* \
  ;

ENV WITH_ODBC=true

RUN cmake -G "Unix Makefiles" -H./ -B./build \
  -D WITH_LUA=${WITH_LUA} \
  -D WITH_MYSQL=${WITH_MYSQL} \
  -D WITH_SQLITE3=${WITH_SQLITE3} \
  -D WITH_PGSQL=${WITH_PGSQL} \
  -D WITH_ODBC=${WITH_ODBC} \
  -D CMAKE_INSTALL_PREFIX=/ \
  ../ && cd build && make

################################################################################
FROM build-${MODE} AS build

### Install
WORKDIR /src/build
RUN make install && chown -R 1001:1001 /var/pvpgn /etc/pvpgn

################################################################################
FROM alpine:latest AS runner-plain

### Install dependencies
RUN apk --quiet --no-cache add \
  ca-certificates \
  libstdc++ \
  libgcc \
  libcurl \
  lua5.1-libs \
  && rm -rf /var/cache/apk/* \
  ;

################################################################################
FROM runner-plain AS runner-mysql

### Install dependencies
RUN apk --quiet --no-cache add \
  mariadb-connector-c \
  && rm -rf /var/cache/apk/* \
  ;

################################################################################
FROM runner-plain AS runner-pgsql

### Install dependencies
RUN apk --quiet --no-cache add \
  libpq \
  && rm -rf /var/cache/apk/* \
  ;

################################################################################
FROM runner-plain AS runner-sqlite3

### Install dependencies
RUN apk --quiet --no-cache add \
  sqlite-libs \
  && rm -rf /var/cache/apk/* \
  ;

################################################################################
FROM runner-plain AS runner-odbc

## Install dependencies
RUN apk --quiet --no-cache add \
  unixodbc \
  && rm -rf /var/cache/apk/* \
  ;

################################################################################
FROM runner-${MODE} AS runner

### Copy build files
COPY --from=build \
  /sbin/bnetd \
  /sbin/bntrackd \
  /sbin/d2cs \
  /sbin/d2dbs \
  /sbin
COPY --from=build \
  /bin/bn* \
  /bin/sha1hash \
  /bin/tgainfo \
  /bin
COPY --from=build --chown=1001:1001 /etc/pvpgn /etc/pvpgn
COPY --from=build --chown=1001:1001 /var/pvpgn /var/pvpgn

### Prepare user
RUN addgroup --gid 1001 pvpgn \
  && adduser \
  --home /var/pvpgn \
  --gecos "" \
  --shell /sbin/nologin \
  --ingroup pvpgn \
  --system \
  --disabled-password \
  --no-create-home \
  --uid 1001 \
  pvpgn

### persist data and configs
VOLUME /var/pvpgn
VOLUME /etc/pvpgn

# expose served network ports
EXPOSE 6112 4000

### Set user
USER 1001:1001

### RUN!
CMD ["bnetd", "-f"]
ENTRYPOINT ["bnetd"]
