#!/bin/bash
echo $@
./docker-helper.sh aarch64-unknown-linux-gnu-gcc $@
