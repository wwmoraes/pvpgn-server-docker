#!/bin/bash

set -Eeuo pipefail

[[ "$#" -ne 2 ]] && {
  echo "usage: $0 <etc-volume-name> <var-volume-name>"
  exit 2
}

for target in etc var; do
  VOLUME_NAME=$1
  shift

  echo -e "creating temporary directory for \033[95m$target\033[m files..."
  TMP=$(mktemp -d)

  echo -e "copying \033[95m$target\033[m files into temporary directory..."
  docker run --rm -v $TMP:/mnt/$target wwmoraes/pvpgn-server cp -r /usr/local/pvpgn/$target/pvpgn /mnt/$target

  echo -e "creating volume \033[96m$VOLUME_NAME\033[m..."
  docker volume create $VOLUME_NAME > /dev/null

  echo -e "copying \033[95m$target\033[m files into \033[96m$VOLUME_NAME\033[m..."
  docker run --rm -v $VOLUME_NAME:/mnt/volume -v $TMP:/mnt/tmp busybox cp -r /mnt/tmp/pvpgn /mnt/volume

  echo -e "adjusting permissions \033[96m$VOLUME_NAME\033[m..."
  docker run --rm -v $VOLUME_NAME:/mnt/volume busybox chown -R 1001:1001 /mnt/volume

  echo -e "removing temporary directory..."
  rm -rf $TMP
done

# TMP_ETC=$(mktemp -d)
# echo "copying etc files into temporary directory..."
# docker run --rm -v $TMP_ETC:/mnt/etc wwmoraes/pvpgn-server cp -r /usr/local/pvpgn/etc/pvpgn /mnt/etc

# docker volume create $ETC_VOLUME_NAME
# echo "copying etc files into new volume..."
# docker run --rm -v $ETC_VOLUME_NAME:/mnt/volume -v $TMP_ETC:/mnt/tmp busybox cp -r /mnt/tmp/pvpgn /mnt/volume
# docker run --rm -v $ETC_VOLUME_NAME:/mnt/volume busybox chown -R 1001:1001 /mnt/volume

# rm -rf $TMP_ETC

# TMP_VAR=$(mktemp -d)
# echo "copying var files into temporary directory..."
# docker run --rm -v $TMP_VAR:/mnt/var wwmoraes/pvpgn-server cp -r /usr/local/pvpgn/var/pvpgn /mnt/var

# docker volume create $VAR_VOLUME_NAME
# echo "copying var files into new volume..."
# docker run --rm -v $VAR_VOLUME_NAME:/mnt/volume -v $TMP_VAR:/mnt/tmp busybox cp -r /mnt/tmp/pvpgn /mnt/volume
# docker run --rm -v $VAR_VOLUME_NAME:/mnt/volume busybox chown -R 1001:1001 /mnt/volume

# rm -rf $TMP_VAR

echo "done!"
