#!/bin/bash

OUTPUT_FUZZ=${TARGET}/output_fuzz
OUTPUT_COV=${TARGET}/output_cov

hopper compile --header ${TARGET}/repo/include/ares.h \
        --library ${TARGET}/build_fuzz/lib/libcares.so.2.6.1 \
        --output ${OUTPUT_FUZZ}

timeout -k 5m $TIMEOUT hopper fuzz ${OUTPUT_FUZZ}

hopper compile --instrument cov --header ${TARGET}/repo/include/ares.h \
       --library ${TARGET}/build_cov/lib/libcares.so.2.6.1 \
       --output ${OUTPUT_COV}
SEED_DIR=${OUTPUT_FUZZ}/queue hopper cov ${OUTPUT_COV}
