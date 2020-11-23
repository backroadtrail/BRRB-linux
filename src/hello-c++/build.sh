#!/usr/bin/env bash

mkdir -p build
pushd build || exit 1
cmake ..
make
./hello-c++
popd || exit 1