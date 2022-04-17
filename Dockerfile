# Copyright (c) 2020-2021 Intel Corporation.
# SPDX-License-Identifier: BSD-3-Clause
FROM ubuntu:18.04
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    gpg-agent \
    software-properties-common \
 && rm -rf /var/lib/apt/lists/* \
 && curl -fsSL https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS-2023.PUB | apt-key add - \
 && echo "deb [trusted=yes] https://apt.repos.intel.com/oneapi all main " > /etc/apt/sources.list.d/oneAPI.list \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    build-essential \
    pkg-config \
    gnupg \
    intel-oneapi-common-vars \
    intel-oneapi-compiler-dpcpp-cpp \
    intel-oneapi-compiler-dpcpp-cpp-and-cpp-classic \
    intel-oneapi-compiler-fortran \
 && rm -rf /var/lib/apt/lists/*

# install cmake
RUN mkdir -p /opt && mkdir -p /opt/build && cd /opt/build \
 && curl -L https://github.com/Kitware/CMake/releases/download/v3.23.1/cmake-3.23.1-linux-x86_64.sh --output cmake.sh \
 && mkdir -p /opt/dist/usr/local \
 && /bin/bash cmake.sh --prefix=/opt/dist/usr/local --skip-license

RUN ls /opt/intel/oneapi

ENV LANG=C.UTF-8
