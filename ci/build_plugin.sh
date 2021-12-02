#!/bin/bash

set -e
#apt-get update 
#apt-get install --no-install-recommends --no-install-suggests -y \
#                build-essential \
#                cmake \
#                wget \
#                git \
#                ca-certificates

export OPENTRACING_VERSION=1.6.0

# Compile for a portable cpu architecture
export CFLAGS="-march=x86-64"
export CXXFLAGS="-march=x86-64"

# Install libcurl
CURL_VERSION=7.59.0
cd "${BUILD_DIR}"
wget --no-check-certificate https://curl.haxx.se/download/curl-${CURL_VERSION}.tar.gz
tar zxf curl-${CURL_VERSION}.tar.gz
cd curl-${CURL_VERSION}
./configure --prefix="${BUILD_DIR}" \
            --disable-ftp \
            --disable-ldap \
            --disable-dict \
            --disable-telnet \
            --disable-tftp \
            --disable-pop3 \
            --disable-smtp \
            --disable-gopher \
            --without-ssl \
            --disable-crypto-auth \
            --without-axtls \
            --disable-rtsp \
            --enable-shared=no \
            --enable-static=yes \
            --with-pic
make && make install
echo ===============================    END OF BUILD CURL =======================
# Build OpenTracing
cd "${BUILD_DIR}"
git clone -b v$OPENTRACING_VERSION https://github.com/opentracing/opentracing-cpp.git
cd opentracing-cpp
mkdir .build && cd .build
cmake -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_CXX_FLAGS="-fPIC" \
      -DCMAKE_INSTALL_PREFIX="${BUILD_DIR}" \
      -DBUILD_SHARED_LIBS=OFF \
      -DBUILD_TESTING=OFF \
      -DBUILD_MOCKTRACER=OFF \
      ..
make && make install
echo =============================== END OF BUILD OPENTRACING ====================================
# Build zipkin
cd "${BUILD_DIR}"
mkdir zipkin-cpp-opentracing && cd zipkin-cpp-opentracing
echo Current directory is $(pwd) and I will use sources from $SRC_DIR

cmake -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX="${BUILD_DIR}" \
      -DBUILD_SHARED_LIBS=OFF \
      -DBUILD_STATIC=OFF \
      -DBUILD_TESTING=OFF \
      -DCURL_INCLUDE_DIRS="${BUILD_DIR}/include" \
      -DBUILD_PLUGIN=ON \
      "${SRC_DIR}"
echo "BEGIN BUID OF PLUGIN"
make && make install
cp "${BUILD_DIR}"/lib/libzipkin_opentracing_plugin.so /
echo =============================== SUCCESS BUILD ============================================
