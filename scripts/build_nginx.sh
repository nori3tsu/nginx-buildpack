#!/bin/bash
#
# Required:
# $ heroku config:set AWS_S3_URL=http://public-bucket.s3-ap-northeast-1.amazonaws.com
#
# Options:
# $ heroku config:set NGINX_VERSION=1.5.2
# $ heroku config:set PCRE_VERSION=8.21
# $ heroku config:set NGINX_CONFIGURE_OPTIONS="--with-http_ssl_module --with-http_gzip_static_module"
#
# Run with:
# $ heroku run 'curl http://${AWS_S3_BUCKET}/build_nginx.sh | sh'

NGINX_VERSION=${NGINX_VERSION-1.5.2}
PCRE_VERSION=${PCRE_VERSION-8.21}
CONFIGURE_OPTIONS=${CONFIGURE_OPTIONS-"--with-http_ssl_module --with-http_gzip_static_module"}

nginx_tarball_url=http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
pcre_tarball_url=http://garr.dl.sourceforge.net/project/pcre/pcre/${PCRE_VERSION}/pcre-${PCRE_VERSION}.tar.bz2

echo "Downloading $nginx_tarball_url"
curl $nginx_tarball_url | tar xzf -

cd nginx-${NGINX_VERSION}

echo "Downloading $pcre_tarball_url"
curl $pcre_tarball_url | tar xjf -

./configure ${CONFIGURE_OPTIONS} --with-pcre=pcre-${PCRE_VERSION} --prefix=$HOME && make install

cd $HOME/sbin

curl \
-F "key=nginx-${NGINX_VERSION}" \
-F "acl=public-read" \
-F "Content-Type=application/octet-stream" \
-F "file=@nginx" \
${AWS_S3_URL}

echo "following: $ curl -o nginx ${AWS_S3_URL}/nginx-${NGINX_VERSION}"
