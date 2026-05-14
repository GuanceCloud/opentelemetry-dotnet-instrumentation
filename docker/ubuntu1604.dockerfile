FROM ubuntu:16.04@sha256:1f1a2d56de1d604801a9671f301190704c25d604a416f59e03c04f5c6ffee0d6

RUN apt-get update && \
    apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    git \
    build-essential software-properties-common \
    gnupg \
    libicu-dev

# Install newer clang
RUN apt-add-repository "deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-5.0 main" && \
    apt-get update && \
    apt-get install -y --allow-unauthenticated clang-5.0 && \
    update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-5.0 1000 && \
    update-alternatives --install /usr/bin/clang clang /usr/bin/clang-5.0 1000 && \
    update-alternatives --config clang && \
    update-alternatives --config clang++

# Install newer g++
RUN add-apt-repository ppa:ubuntu-toolchain-r/test -y && \
    apt-get update && \
    apt-get install -y g++-9 && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 60 --slave /usr/bin/g++ g++ /usr/bin/g++-9

# Install a deterministic CMake version compatible with the native build.
RUN curl -fsSL --retry 5 --retry-delay 5 https://github.com/Kitware/CMake/releases/download/v3.19.8/cmake-3.19.8-Linux-x86_64.tar.gz -o /tmp/cmake.tar.gz && \
    tar -C /opt -xzf /tmp/cmake.tar.gz && \
    ln -s /opt/cmake-3.19.8-Linux-x86_64/bin/cmake /usr/local/bin/cmake && \
    ln -s /opt/cmake-3.19.8-Linux-x86_64/bin/ctest /usr/local/bin/ctest && \
    ln -s /opt/cmake-3.19.8-Linux-x86_64/bin/cpack /usr/local/bin/cpack && \
    rm /tmp/cmake.tar.gz

COPY ./scripts/dotnet-install.sh ./dotnet-install.sh

RUN chmod +x ./dotnet-install.sh \
    && ./dotnet-install.sh -v 9.0.312 --install-dir /usr/share/dotnet --no-path \
    && rm dotnet-install.sh

ENV IsLegacyUbuntu=true

WORKDIR /project
