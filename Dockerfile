FROM ubuntu:20.04

ENV HOPPER_BIN=/hopper/hopper \
    RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/hopper:/usr/local/cargo/bin:/root/.cargo/bin:$PATH \
    DEBIAN_FRONTEND=noninteractive 

# RUN sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
# RUN sed -i 's/security.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get -y install build-essential wget curl cmake git unzip xxd protobuf-compiler libprotobuf-dev \
    && apt-get -y install llvm-dev libclang-dev clang \
    && apt-get -y install zsh python3 python3-dev python3-setuptools python-is-python3 python3-venv python3-pip vim \
    && apt-get clean

RUN pip3 install ipython
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# ENV RUSTUP_DIST_SERVER="https://mirrors.ustc.edu.cn/rust-static"
# ENV RUSTUP_UPDATE_ROOT="https://mirrors.ustc.edu.cn/rust-static/rustup"

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable

# RUN echo '[source.crates-io]' > ${CARGO_HOME}/config && \
#    echo "replace-with = 'tencent'" >> ${CARGO_HOME}/config && \
#    echo '[source.tencent]' >> ${CARGO_HOME}/config && \
#    echo 'registry = "http://mirrors.tencent.com/rust/index"' >> ${CARGO_HOME}/config

RUN mkdir -p /hopper
COPY . /hopper
WORKDIR /hopper

RUN ./build.sh

# RUN mkdir /llvm
# ENV PATH=/llvm/bin:$PATH
# ENV LD_LIBRARY_PATH=/llvm/lib:$LD_LIBRARY_PATH

RUN mkdir /fuzz_lib
RUN mkdir /fuzz
WORKDIR /fuzz
