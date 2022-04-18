# Copyright (c) 2020-2021 Intel Corporation.
# SPDX-License-Identifier: BSD-3-Clause
FROM ubuntu:18.04
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    git \
    gpg-agent \
    libbz2-dev \
    software-properties-common \
    ninja-build \
    unzip \
    wget \
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

# BOOST 1.60 with Boost geometry extensions
# SSC : system thread random chrono
# XDYN : program_options filesystem system regex
# libbz2 is required for Boost compilation
RUN . ./opt/intel/oneapi/setvars.sh \
 && wget http://sourceforge.net/projects/boost/files/boost/1.60.0/boost_1_60_0.tar.gz -O boost_src.tar.gz \
 && mkdir -p boost_src \
 && tar -xzf boost_src.tar.gz --strip 1 -C boost_src \
 && rm -rf boost_src.tar.gz \
 && cd boost_src \
 && ./bootstrap.sh --with-toolset=intel-linux \
 && ./b2 cxxflags=-fPIC --without-mpi --without-python link=static threading=single threading=multi --layout=tagged --prefix=/opt/boost install \
 && cd .. \
 && rm -rf boost_src
# BOOST Geometry extension
RUN git clone https://github.com/boostorg/geometry \
 && cd geometry \
 && git checkout 4aa61e59a72b44fb3c7761066d478479d2dd63a0 \
 && cp -rf include/boost/geometry/extensions /opt/boost/include/boost/geometry/. \
 && cd .. \
 && rm -rf geometry

# Ipopt
# http://www.coin-or.org/Ipopt/documentation/node10.html
ENV IPOPT_VERSION=3.12.9
RUN gfortran --version \
 && wget http://www.coin-or.org/download/source/Ipopt/Ipopt-$IPOPT_VERSION.tgz -O ipopt_src.tgz \
 && mkdir -p ipopt_src \
 && tar -xf ipopt_src.tgz --strip 1 -C ipopt_src \
 && rm -rf ipopt_src.tgz \
 && cd ipopt_src \
 && cd ThirdParty/Blas \
 &&     ./get.Blas \
 && cd ../Lapack \
 &&     ./get.Lapack \
 && cd ../Mumps \
 &&     ./get.Mumps \
 && cd ../../ \
 && mkdir build \
 && cd build \
 && ../configure -with-pic --disable-shared --prefix=/opt/CoinIpopt \
 && make \
 && make test \
 && make install \
 && cd .. \
 && cd .. \
 && rm -rf ipopt_src

RUN wget https://github.com/eigenteam/eigen-git-mirror/archive/3.3.5.tar.gz -O eigen.tgz \
 && mkdir -p /opt/eigen \
 && tar -xzf eigen.tgz --strip 1 -C /opt/eigen \
 && rm -rf eigen.tgz

RUN wget https://github.com/jbeder/yaml-cpp/archive/release-0.3.0.tar.gz -O yaml_cpp.tgz \
 && mkdir -p /opt/yaml_cpp \
 && tar -xzf yaml_cpp.tgz --strip 1 -C /opt/yaml_cpp \
 && rm -rf yaml_cpp.tgz

RUN wget https://github.com/google/googletest/archive/release-1.8.0.tar.gz -O googletest.tgz \
 && mkdir -p /opt/googletest \
 && tar -xzf googletest.tgz --strip 1 -C /opt/googletest \
 && rm -rf googletest.tgz

RUN wget https://github.com/zaphoyd/websocketpp/archive/0.7.0.tar.gz -O websocketpp.tgz \
 && mkdir -p /opt/websocketpp \
 && tar -xzf websocketpp.tgz --strip 1 -C /opt/websocketpp \
 && rm -rf websocketpp.tgz

RUN mkdir -p /opt/libf2c \
 && cd /opt/libf2c \
 && wget http://www.netlib.org/f2c/libf2c.zip -O libf2c.zip \
 && unzip libf2c.zip \
 && rm -rf libf2c.zip

RUN wget https://sourceforge.net/projects/geographiclib/files/distrib/archive/GeographicLib-1.30.tar.gz/download -O geographiclib.tgz \
 && mkdir -p /opt/geographiclib \
 && tar -xzf geographiclib.tgz --strip 1 -C /opt/geographiclib \
 && rm -rf geographiclib.tgz