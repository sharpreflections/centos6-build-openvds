FROM quay.io/sharpreflections/centos6-build
LABEL maintainer="juergen.wind@sharpreflections.com"

ARG gcc=gcc-8.3.1
ARG curl_version=7.80.0
ARG openssl_version=1_0_2t
ARG boost_version=1_72_0
ARG boost_download_subdir=1.72.0
ARG openvds_version=2.1.8

WORKDIR /build/

COPY  openssl-OpenSSL_$openssl_version.tar.gz /build/
COPY  curl-$curl_version.tar.bz2 /build/
COPY  open-vds-$openvds_version.tar.bz2 /build/
COPY  no_tools.patch /build/


ENV CC=gcc
ENV CXX=g++

RUN . /opt/rh/devtoolset-8/enable && \
    . /opt/rh/sclo-git212/enable && \
    yum install -y libuuid-devel && \
    export PATH=/opt/ninja/bin:$PATH && \
    #Install openssl 
    tar xf openssl-OpenSSL_$openssl_version.tar.gz && cd openssl-OpenSSL_$openssl_version && \
    ./config --prefix=/opt/openssl no-shared -D_POSIX_C_SOURCE=199506L -D_SVID_SOURCE -fPIC && \
    make install && \
    cd .. && \
    \
    #Install curl 
    tar xf curl-$curl_version.tar.bz2 && cd curl-$curl_version && \
    ./configure --prefix=/opt/curl --disable-shared --with-openssl=/opt/openssl && \
    make install && \
    \
    cd .. && \
    \
    #Install boost
    echo "Downloading Boost" &&\
    curl --remote-name --location https://boostorg.jfrog.io/artifactory/main/release/$boost_download_subdir/source/boost_$boost_version.tar.bz2 &&\
    tar xf boost_$boost_version.tar.bz2 && cd boost_$boost_version && \
    ./bootstrap.sh --without-libraries=python  --prefix=/opt/boost/ && \
    ./b2 -j 4 link=static,shared toolset=gcc install && \
    \
    cd .. && \
    \
    #Build OpenVDS  
    tar xf open-vds-$openvds_version.tar.bz2 && cd open-vds-$openvds_version && \
    patch -Np1 <../no_tools.patch && \
    mkdir build && cd build && \
    LDFLAGS=-L/opt/curl/lib\ -L/opt/openssl/lib CXXFLAGS=-isystem\ /opt/openssl/include\ -isystem\ /opt/curl/include  CMAKE_PREFIX_PATH=/opt/curl:/opt/boost:/opt/openssl/ /opt/cmake-3.20.1-linux-x86_64/bin/cmake -DBUILD_TESTS:BOOL=OFF -DBUILD_EXAMPLES:BOOL=OFF -DBUILD_UV:BOOL=ON -DCMAKE_INSTALL_PREFIX:PATH=/opt/openvds -GNinja ../ && \
    LDFLAGS=-L/opt/curl/lib\ -L/opt/openssl/lib CXXFLAGS=-isystem\ /opt/openssl/include\ -isystem\ /opt/curl/include CMAKE_PREFIX_PATH=/opt/curl:/opt/boost:/opt/openssl/  ninja -j 4 install 
