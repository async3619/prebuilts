#!/usr/bin/env bash

export GIT_FETCH_JOBS=8

git clone --depth 1 -b master https://github.com/boostorg/boost
cd ./boost

git submodule init tools/build tools/boostdep tools/boost_install libs/headers libs/config libs/filesystem
git submodule update --jobs ${GIT_FETCH_JOBS}

python tools/boostdep/depinst/depinst.py --git_args "--jobs ${GIT_FETCH_JOBS}" filesystem

bash ./bootstrap.sh

export BUILD_OPTION="link=static threading=multi warnings=off define=BOOST_TYPE_INDEX_FORCE_NO_RTTI_COMPATIBILITY"

if [[ "$CONFIGURATION" == "Debug" ]]; then
    export BUILD_OPTION="${BUILD_OPTION} variant=debug debug-symbols=on optimization=off";
else
    export BUILD_OPTION="${BUILD_OPTION} variant=release debug-symbols=off optimization=speed";
fi

# build first
./b2 -j${CPU_COUNTS} address-model=32 ${BUILD_OPTION} stage
./b2 -d0 -j${CPU_COUNTS} --prefix=./${BRANCH_NAME}-x86 address-model=32 ${BUILD_OPTION} install

./b2 -j${CPU_COUNTS} address-model=64 ${BUILD_OPTION} stage
./b2 -d0 -j${CPU_COUNTS} --prefix=./${BRANCH_NAME}-x64 address-model=64 ${BUILD_OPTION} install

cd ..