#!/bin/bash

set -e

##
# Pre-requirements:
# - env TARGET: path to target work dir
# - env OUT: path to directory where artifacts are stored
# - env CC, CXX, FLAGS, LIBS, etc...
##

if [ ! -d "$TARGET/repo" ]; then
    echo "fetch.sh must be executed first."
    exit 1
fi

export LLVM_COMPILER_PATH=/usr/bin
export CC="$LLVM_COMPILER_PATH"/clang
export CXX="$LLVM_COMPILER_PATH"/clang++

echo "make 1"
mkdir -p "$TARGET/build_cov"
cp -r $TARGET/repo/* "$TARGET/build_cov"
cd "$TARGET/build_cov"

export CXXFLAGS="-fprofile-instr-generate -fcoverage-mapping -g"
export CFLAGS="-fprofile-instr-generate -fcoverage-mapping -g"

# oss-fuzz has 2 GB total memory allocation limit. So, we limit per-allocation
# limit in libvpx to 1 GB to avoid OOM errors. A smaller per-allocation is
# needed for MemorySanitizer (see bug oss-fuzz:9497 and bug oss-fuzz:9499).
if [[ $CFLAGS = *sanitize=memory* ]]; then
  extra_c_flags='-DVPX_MAX_ALLOCABLE_MEMORY=536870912'
else
  extra_c_flags='-DVPX_MAX_ALLOCABLE_MEMORY=1073741824'
fi

LDFLAGS="$CXXFLAGS" LD=$CXX $TARGET/build_cov/configure \
    --enable-vp9-highbitdepth \
    --disable-unit-tests \
    --disable-examples \
    --size-limit=12288x12288 \
    --extra-cflags="${extra_c_flags}" \
    --disable-webm-io \
    --enable-shared  \
    --disable-static \
    --enable-debug
make -j all

# Build libvpx for fuzzing
cd -
mkdir -p "$TARGET/build_fuzz"
cp -r $TARGET/repo/* $TARGET/build_fuzz
cd "$TARGET/build_fuzz"

# oss-fuzz has 2 GB total memory allocation limit. So, we limit per-allocation
# limit in libvpx to 1 GB to avoid OOM errors. A smaller per-allocation is
# needed for MemorySanitizer (see bug oss-fuzz:9497 and bug oss-fuzz:9499).
if [[ $CFLAGS = *sanitize=memory* ]]; then
  extra_c_flags='-DVPX_MAX_ALLOCABLE_MEMORY=536870912'
else
  extra_c_flags='-DVPX_MAX_ALLOCABLE_MEMORY=1073741824'
fi

LDFLAGS="$CXXFLAGS" LD=$CXX  $TARGET/build_fuzz/configure \
    --enable-vp9-highbitdepth \
    --disable-unit-tests \
    --disable-examples \
    --size-limit=12288x12288 \
    --extra-cflags="${extra_c_flags}" \
    --disable-webm-io \
    --disable-debug \
    --enable-shared  \
    --disable-static
make clean
make -j all

cd -

cp ${TARGET}/../../targets/libvpx/vpx_all.h ${TARGET}/repo/