#!/usr/bin/env bash

export GIT_FETCH_JOBS=8
export CPU_COUNTS=$(nproc --all)

git clone --depth 1 -b master https://github.com/boostorg/boost
cd ./boost

git submodule init tools/build tools/boostdep tools/boost_install libs/headers libs/config libs/filesystem
git submodule update --jobs ${GIT_FETCH_JOBS} --depth 1

python tools/boostdep/depinst/depinst.py --git_args "--jobs ${GIT_FETCH_JOBS} --depth 1" filesystem

bash ./bootstrap.sh

# build first
./b2 -j${CPU_COUNTS} address-model=32 link=static variant=release debug-symbols=off optimization=speed threading=multi warnings=off stage
./b2 -d0 -j${CPU_COUNTS} --prefix=./boost-x86 address-model=32 link=static variant=release debug-symbols=off optimization=speed threading=multi warnings=off install

./b2 -j${CPU_COUNTS} address-model=64 link=static variant=release debug-symbols=off optimization=speed threading=multi warnings=off stage
./b2 -d0 -j${CPU_COUNTS} --prefix=./boost-x64 address-model=64 link=static variant=release debug-symbols=off optimization=speed threading=multi warnings=off install
