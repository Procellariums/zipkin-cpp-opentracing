#!/bin/sh


if [ -z "$BUILD_DIR"];
 then
  echo "Build dir is not set"
  exit 1
 fi

cd $BUILD_DIR
echo Build dir is $BUILD_DIR 

echo Download nginx
wget https://nginx.org/download/nginx-1.17.3.tar.gz

echo Extract nginx
tar xzf nginx-1.17.3.tar.gz

cd nginx-1.17.3

echo Clone plugin sources

git clone https://github.com/opentracing-contrib/nginx-opentracing.git

echo Install necessary libs for building of nginx-plugin

yum -y install pcre pcre-devel zlib zlib-devel


echo Setup module
sed -i -e 's/^ngx_module_incs.*$/ngx_module_incs=$BUILD_DIR\/include/' -e 's/^ngx_module_libs=.*$/ngx_module_libs="-lstdc++ $BUILD_DIR\/lib\/libopentracing\.a"/' nginx-opentracing/opentracing/config

echo Configure module

./configure --with-compat --add-dynamic-module=./nginx-opentracing/opentracing

echo Build nginx plugin
make modules

echo Install
cp objs/ngx_http_opentracing_module.so /
