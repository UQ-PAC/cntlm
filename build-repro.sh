#!/bin/bash

export DOCKER_FLAKE='github:katrinafyi/pac-nix/ef9c23743bddd6cf8d6b656c460c572426b50c9a#basil-tools-docker'

# run first:
#   using https://github.com/UQ-PAC/BASIL/blob/e9ad1001fb08b91209728ebe30a74c84831f3c0f/src/test/make/docker-helper.sh
#   export DOCKER_FLAKE='github:katrinafyi/pac-nix/ef9c23743bddd6cf8d6b656c460c572426b50c9a#basil-tools-docker'
#   docker-helper.sh pull
#   docker-helper.sh start

ROOT=$(git rev-parse --show-toplevel)
CONT=docker-helper.sh

export CC="$CONT aarch64-unknown-linux-gnu-gcc"
$CONT start
rm -rf build
cmake -B build . -DENABLE_DUK=1 
cmake --build build
mkdir -p package
cp build/cntlm-noduk package/cntlm-noduk
cp build/cntlm-duk package/cntlm-duk

cd package
list='cntlm-noduk cntlm-duk'
for NAME in $list; do
  $CONT aarch64-unknown-linux-musl-readelf $NAME -s -r -W > $NAME.relf
  $CONT bap -d adt:$NAME.adt -d bir:$NAME.bir $NAME 
  $CONT ddisasm $NAME --ir $NAME.gtirb 
  $CONT gtirb-semantics $NAME.gtirb $NAME.gts
done

md5sum $(ls | grep -v '.md5') > checksum.md5

md5sum -c checksum.md5
echo "Created from $(git remote get-url origin) $(git show-ref HEAD)" > readme.txt

cd ..
$CONT stop
