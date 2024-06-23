#!/usr/bin/env sh

docker run --rm  \
  --name=acme.sh.exec \
  neilpang/acme.sh \
  "$@"
