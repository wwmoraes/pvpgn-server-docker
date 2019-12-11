FROM alpine as builder

ARG REPO=https://github.com/pvpgn/pvpgn-server.git
ARG WITH_MYSQL=true
ARG WITH_LUA=true

### Install build dependencies
RUN apk add git build-base clang cmake make zlib-dev lua-dev mariadb-dev

### CMake & make
RUN git clone ${REPO} /src
RUN mkdir build
WORKDIR /src/build
RUN mkdir /usr/local/pvpgn
RUN cmake \
  -D WITH_MYSQL=${WITH_MYSQL} \
  -D WITH_LUA=${WITH_LUA} \
  -D CMAKE_INSTALL_PREFIX=/usr/local/pvpgn \
  -w \
  ../

### Install
RUN make
RUN make install

FROM alpine as runner

### Install dependencies
RUN apk --no-cache add ca-certificates libstdc++ libgcc lua5.1-libs mariadb-connector-c

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
