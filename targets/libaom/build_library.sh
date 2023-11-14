#!/bin/bash

set -e
set -x

# NOTE: if TOOLD_DIR is unset, I assume to find stuffs in LIBFUZZ folder
if [ -z "$TOOLS_DIR" ]; then
    TOOLS_DIR=$LIBFUZZ
fi

export LLVM_COMPILER_PATH=/usr/bin
export CC="$LLVM_COMPILER_PATH"/clang
export CXX="$LLVM_COMPILER_PATH"/clang++

echo "make 1"
mkdir -p "$TARGET/build_cov"
cd "$TARGET/build_cov"

# Compile library for coverage
cmake ../repo -DBUILD_SHARED_LIBS=off \
        -DENABLE_STATIC=on -DCMAKE_BUILD_TYPE=Debug \
        -DCMAKE_C_FLAGS_DEBUG="-fprofile-instr-generate -fcoverage-mapping -g" \
        -DCMAKE_CXX_FLAGS_DEBUG="-fprofile-instr-generate -fcoverage-mapping -g"

echo "make clean"
make -j"$(nproc)" clean
echo "make"
make -j"$(nproc)"
echo "make install"
make install

cd ..
mkdir -p "$TARGET/build_fuzz"
cd "$TARGET/build_fuzz"

# Compile library for fuzzing
cmake ../repo -DBUILD_SHARED_LIBS=on \
        -DENABLE_STATIC=off -DCMAKE_BUILD_TYPE=Release

echo "make clean"
make -j"$(nproc)" clean
echo "make"
make -j"$(nproc)"
echo "make install"
make install

cp ${TARGET}/../../targets/libaom/aom_all.h ${TARGET}/repo/aom/