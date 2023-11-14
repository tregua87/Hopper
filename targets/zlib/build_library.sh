#!/bin/bash
set -e

##
# Pre-requirements:
# - env TARGET: path to target work dir
# - env OUT: path to directory where artifacts are stored
# - env CC, CXX, FLAGS, LIBS, etc...
##

# export TARGET=/tmp/libtiff

if [ ! -d "$TARGET/repo" ]; then
    echo "fetch.sh must be executed first."
    exit 1
fi

export CC=$LLVM_DIR/bin/clang
export CXX=$LLVM_DIR/bin/clang++
export LIBFUZZ_LOG_PATH=$WORK/apipass

echo "make 1"
mkdir -p "$TARGET/build_cov"
cd "$TARGET/build_cov"

echo "cmake"
# Compile library for coverage
cmake ../repo -DBUILD_SHARED_LIBS=on \
        -DENABLE_STATIC=off -DCMAKE_BUILD_TYPE=Debug \
        -DCMAKE_C_FLAGS_DEBUG="-fprofile-instr-generate -fcoverage-mapping -g" \
        -DCMAKE_CXX_FLAGS_DEBUG="-fprofile-instr-generate -fcoverage-mapping -g" \
        -DBENCHMARK_ENABLE_GTEST_TESTS=off \
        -DBENCHMARK_ENABLE_INSTALL=off

echo "make clean"
make -j$(nproc) clean
echo "make"
make -j$(nproc)

cd ..
mkdir -p "$TARGET/build_fuzz"
cd "$TARGET/build_fuzz"

cmake ../repo -DBUILD_SHARED_LIBS=on \
        -DENABLE_STATIC=off -DCMAKE_BUILD_TYPE=Release \
        -DBENCHMARK_ENABLE_GTEST_TESTS=off \
        -DBENCHMARK_ENABLE_INSTALL=off

echo "make clean"
make -j$(nproc) clean
echo "make"
make -j$(nproc)

