#!/bin/bash

ROOT=$(git rev-parse --show-toplevel)
CONT=$ROOT/docker-helper.sh
export CC="$CONT aarch64-unknown-linux-musl-gcc"
$CONT start
# rm -rf build
# cmake -B build . -DENABLE_DUK=1 
# cmake --build build
# mkdir -p package
# cp build/cntlm-noduk package/cntlm-noduk-musl
# cp build/cntlm-duk package/cntlm-duk-musl

names=(
  cntlm-noduk-musl
  cntlm-duk-musl
)

for NAME in $names; do
  cd package
  $CONT aarch64-unknown-linux-musl-readelf $NAME -s -r -W > $NAME.relf
  $CONT bap -d adt:$NAME.adt -d bir:$NAME.bir $NAME 
  $CONT ddisasm $NAME --ir $NAME.gtirb 
  $CONT gtirb-semantics $NAME.gtirb $NAME.gts
  rm $NAME.gtirb
done

$CONT md5sum * > checksum.md5
echo "Created from $(git remote get-url origin) $(git show-ref HEAD)" > readme.txt




$CONT stop
