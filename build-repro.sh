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

cd package
list='cntlm-noduk-musl cntlm-duk-musl'
for NAME in $list; do
  $CONT aarch64-unknown-linux-musl-readelf $NAME -s -r -W > $NAME.relf
  $CONT bap -d adt:$NAME.adt -d bir:$NAME.bir $NAME 
  $CONT ddisasm $NAME --ir $NAME.gtirb 
  $CONT gtirb-semantics $NAME.gtirb $NAME.gts
done

#md5sum $(ls | grep -v '.md5') > checksum.md5

md5sum -c checksum.md5
echo "Created from $(git remote get-url origin) $(git show-ref HEAD)" > readme.txt

cd ..
$CONT stop
