#!/bin/bash

if [ "$#" -lt 1 ]; then
    echo "Usage: ./run_target.sh TARGET [TIMEOUT]"
    echo "Supported targets:"
    ls ./targets
    exit 1
fi

export TARGET_NAME=$1

if [ "$#" -ne 2 ]; then
    echo "[INFO] Using default timeout 2m"
    export TIMEOUT=2m
else
    echo "[INFO] Timeout set to $2"
    export TIMEOUT=$2
fi

# echo "$(ls ./targets)"

if [[ ! -d "./targets/${TARGET_NAME}" ]]; then
    echo "Target ${TARGET_NAME} is not valid"
    exit 1
fi

./targets/${TARGET_NAME}/preinstall.sh

PLAYGROUND_DIR="$(pwd)/playground"

echo "[INFO] Target '${TARGET_NAME}' is valid!"

if [[ ! -d ${PLAYGROUND_DIR} ]]; then
    echo "[INFO] Creating '${PLAYGROUND_DIR}'"
    mkdir -p ${PLAYGROUND_DIR}
else 
    echo "[INFO] '${PLAYGROUND_DIR}' already exists"
fi

export TARGET="${PLAYGROUND_DIR}/${TARGET_NAME}"

if [[ ! -d ${TARGET} ]]; then
    echo "[INFO] Creating '${TARGET}'"
    mkdir -p ${TARGET}
else 
    echo "[INFO] '${TARGET}' already exists"
fi

if [[ ! -d "${TARGET}/repo" ]]; then
    echo "[INFO] Cloning ${TARGET_NAME}"
    ./targets/${TARGET_NAME}/fetch.sh
else
    echo "[INFO] '${TARGET}/repo' already exists"
fi

./targets/${TARGET_NAME}/build_library.sh

./targets/${TARGET_NAME}/run.sh
