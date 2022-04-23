FROM alpine:latest as builder

### Install build dependencies
RUN apk --quiet --no-cache add \
  git \
  build-base \
  clang \
  cmake \
  make \
  zlib-dev \
  lua-dev \
  mariadb-dev \
  && rm -rf /var/cache/apk/* \
  ;

### CMake & make
ARG REPO=https://github.com/pvpgn/pvpgn-server.git
ARG BRANCH=master
RUN git clone --single-branch --branch ${BRANCH} ${REPO} /src

RUN mkdir /src/build /usr/local/pvpgn
WORKDIR /src/build

ARG WITH_MYSQL=true
ARG WITH_LUA=true
RUN cmake \
  -D WITH_MYSQL=${WITH_MYSQL} \
  -D WITH_LUA=${WITH_LUA} \
  -D CMAKE_INSTALL_PREFIX=/usr/local/pvpgn \
  ../

### Install
RUN make && make install

FROM alpine:latest as runner

### Install dependencies
RUN apk --quiet --no-cache add \
  ca-certificates \
  libstdc++ \
  libgcc \
  lua5.1-libs \
  mariadb-connector-c \
  && rm -rf /var/cache/apk/* \
  ;

### Copy build files
COPY --from=builder /usr/local/pvpgn /usr/local/pvpgn

### Prepare user
RUN addgroup --gid 1001 pvpgn \
  && adduser \
  --home /usr/local/pvpgn \
  --gecos "" \
  --shell /bin/false \
  --ingroup pvpgn \
  --system \
  --disabled-password \
  --no-create-home \
  --uid 1001 \
  pvpgn

### Make volume folders
RUN mkdir -p /usr/local/pvpgn/var
RUN mkdir -p /usr/local/pvpgn/etc
RUN chown -R pvpgn:pvpgn /usr/local/pvpgn/var
RUN chown -R pvpgn:pvpgn /usr/local/pvpgn/etc

### persist data and configs
VOLUME /usr/local/pvpgn/var
VOLUME /usr/local/pvpgn/etc

### adjust permissions
RUN chown -R pvpgn:pvpgn /usr/local/pvpgn

# expose served network ports
EXPOSE 6112 4000

### Set user
USER pvpgn

### RUN!
CMD ["/usr/local/pvpgn/sbin/bnetd", "-f"]
ENTRYPOINT ["/usr/local/pvpgn/sbin/bnetd"]
