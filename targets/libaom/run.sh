#!/bin/bash

OUTPUT_FUZZ=${TARGET}/output_fuzz
OUTPUT_COV=${TARGET}/output_cov

hopper compile --header ${TARGET}/repo/aom/aom_all.h \
        --library ${TARGET}/build_fuzz/libaom.so.3.7.0 \
        --output ${OUTPUT_FUZZ}

timeout -k 5m $TIMEOUT hopper fuzz ${OUTPUT_FUZZ}

hopper compile --instrument cov --header ${TARGET}/repo/aom/aom_all.h \
       --library ${TARGET}/build_cov/libaom.so.3.7.0 \
       --output ${OUTPUT_COV}
SEED_DIR=${OUTPUT_FUZZ}/queue hopper cov ${OUTPUT_COV}
