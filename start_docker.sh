#!/bin/bash

docker build -t hopper ./
docker run --name hopper_dev --privileged -v $(pwd):/fuzz -it --rm hopper /bin/zsh