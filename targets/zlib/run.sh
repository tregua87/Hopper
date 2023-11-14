#!/bin/bash

OUTPUT_FUZZ=${TARGET}/output_fuzz
OUTPUT_COV=${TARGET}/output_cov

# export HOPPER_INCLUDE_SEARCH_PATH="${TARGET}/repo"

hopper compile --header ${TARGET}/repo/zlib.h \
        --library ${TARGET}/build_fuzz/libz.so \
        --output ${OUTPUT_FUZZ}

timeout -k 5m $TIMEOUT hopper fuzz ${OUTPUT_FUZZ}

hopper compile --instrument cov --header ${TARGET}/repo/zlib.h \
       --library ${TARGET}/build_cov/libz.so \
       --output ${OUTPUT_COV}
SEED_DIR=${OUTPUT_FUZZ}/queue hopper cov ${OUTPUT_COV}
