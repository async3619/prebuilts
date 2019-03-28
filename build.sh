#!/usr/bin/env bash

export GIT_FETCH_JOBS=8
if [[ "$TRAVIS_OS_NAME" == "linux" ]]; then
    export GIT_FETCH_DEPTH="--depth 1";
fi


git clone --depth 1 -b master https://github.com/boostorg/boost
cd ./boost

git submodule init tools/build tools/boostdep tools/boost_install libs/headers libs/config libs/filesystem
git submodule update --jobs ${GIT_FETCH_JOBS} ${GIT_FETCH_DEPTH}

python tools/boostdep/depinst/depinst.py --git_args "--jobs ${GIT_FETCH_JOBS} ${GIT_FETCH_DEPTH}" filesystem

bash ./bootstrap.sh

# build first
./b2 -j${CPU_COUNTS} address-model=32 link=static variant=release debug-symbols=off optimization=speed threading=multi warnings=off stage
./b2 -d0 -j${CPU_COUNTS} --prefix=./${BRANCH_NAME}-x86 address-model=32 link=static variant=release debug-symbols=off optimization=speed threading=multi warnings=off install

./b2 -j${CPU_COUNTS} address-model=64 link=static variant=release debug-symbols=off optimization=speed threading=multi warnings=off stage
./b2 -d0 -j${CPU_COUNTS} --prefix=./${BRANCH_NAME}-x64 address-model=64 link=static variant=release debug-symbols=off optimization=speed threading=multi warnings=off install

cd ..