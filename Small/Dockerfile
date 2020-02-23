FROM ubuntu:16.04
ENV DEBIAN_FRONTEND noninteractive
ENV TZ=Europe/Kiev
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends --no-install-suggests \
	software-properties-common git unzip libxml2-dev \
	libbz2-dev libcurl4-openssl-dev libmcrypt-dev libmhash2 \
	libmhash-dev libpcre3 libpcre3-dev make build-essential \
	libxslt1-dev libgd2-xpm-dev libgeoip-dev \
	libpam-dev libgoogle-perftools-dev lua5.1 liblua5.1-0 \
	liblua5.1-0-dev checkinstall wget libssl-dev \
    mercurial meld openssh-server \
    autoconf automake cmake libass-dev libfreetype6-dev \
    libsdl2-dev libtheora-dev libtool libva-dev libvdpau-dev \
    libvorbis-dev libxcb1-dev libxcb-shm0-dev libxcb-xfixes0-dev \
    pkg-config texinfo zlib1g-dev pkgconf libyajl-dev libpcre++-dev liblmdb-dev \
    gettext gnupg2 curl python3 jq ca-certificates gcc g++ \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /usr/share/doc/* \
    && rm -rf /usr/share/man/* \
    && git clone https://github.com/openresty/luajit2.git /usr/src/luajit-2.0 \
    && git clone https://github.com/simpl/ngx_devel_kit.git /usr/src/ngx_devel_kit \
    && git clone https://github.com/openresty/lua-nginx-module.git /usr/src/lua-nginx-module \
    && git clone https://github.com/openresty/echo-nginx-module.git /usr/src/echo-nginx-module \
    && git clone https://github.com/vozlt/nginx-module-vts.git /usr/src/nginx-module-vts \
    && git clone https://github.com/vozlt/nginx-module-stream-sts.git /usr/src/nginx-module-stream-sts \
    && git clone https://github.com/vozlt/nginx-module-sts.git /usr/src/nginx-module-sts \
    && git clone https://github.com/nbs-system/naxsi.git /usr/src/naxsi \
    && git clone https://github.com/kaltura/nginx-vod-module.git /usr/src/nginx-vod-module \
    && git clone https://github.com/arut/nginx-rtmp-module.git /usr/src/nginx-rtmp-module \
    && git clone https://github.com/arut/nginx-ts-module.git /usr/src/nginx-ts-module \
    && git clone https://github.com/openresty/headers-more-nginx-module.git /usr/src/headers-more-nginx-module \
    && git clone https://github.com/yzprofile/ngx_http_dyups_module.git /usr/src/ngx_http_dyups_module \
    && git clone https://github.com/openresty/lua-upstream-nginx-module.git /usr/src/lua-upstream-nginx-module \
    && git clone https://github.com/dburianov/nginx_upstream_check_module.git /usr/src/nginx_upstream_check_module \
    && git clone https://bitbucket.org/nginx-goodies/nginx-sticky-module-ng.git /usr/src/nginx-sticky-module-ng \
    && git clone https://github.com/openresty/lua-resty-core.git /usr/src/lua-resty-core \
    && git clone https://github.com/openresty/lua-resty-lrucache.git /usr/src/lua-resty-lrucache \
    && git clone https://github.com/hnlq715/status-nginx-module.git /usr/src/status-nginx-module \
    && git clone --depth 1 -b v3/master --single-branch https://github.com/SpiderLabs/ModSecurity /usr/src/ModSecurity \
    && git clone --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx.git /usr/src/ModSecurity-nginx \
    && git clone https://github.com/opentracing/opentracing-cpp.git /usr/src/opentracing-cpp \
    && git clone https://github.com/opentracing-contrib/nginx-opentracing.git /usr/src/nginx-opentracing \
    && cd /usr/src/luajit-2.0 \
    && make -j$(nproc) \
    && make install \
    && cd .. \
    && export LUAJIT_LIB=/usr/local/lib \
    && export LUAJIT_INC=/usr/local/include/luajit-2.1 \
    && ldconfig \
    && echo "Compiling ModSecurity" \
    && cd /usr/src \
    && cd ModSecurity \
    && git submodule init \
    && git submodule update \
    && ./build.sh \
    && ./configure \
    && make -j$(nproc) \
    && make install \
    && cd /usr/src \
    && echo "Compiling Nginx" \
    && cd /usr/src/ \
    && hg clone http://hg.nginx.org/nginx \
    && hg clone http://hg.nginx.org/njs \
    && cd /usr/src/nginx \
    && curl -sS https://raw.githubusercontent.com/dburianov/nginx-ffmpeg/master/1.diff | patch -d/ -p0 \
    && curl -sS https://raw.githubusercontent.com/dburianov/nginx-ffmpeg/master/2.diff | patch -d/ -p0 \
    && curl -sS https://raw.githubusercontent.com/dburianov/nginx-ffmpeg/master/3.diff | patch -d/ -p0 \
    && curl -sS https://raw.githubusercontent.com/dburianov/nginx-ffmpeg/master/4.diff | patch -d/ -p0 \
    && curl -sS https://raw.githubusercontent.com/dburianov/nginx-ffmpeg/master/5.diff | patch -d/ -p0 \
    && export ASAN_OPTIONS=detect_leaks=0  \
    && export CFLAGS="-Wno-error" \
    && cp ./auto/configure . \
    && ./configure \
    --with-http_xslt_module \
    --with-http_ssl_module \
    --with-http_mp4_module \
    --with-http_flv_module \
	--with-http_secure_link_module \
    --with-http_dav_module \
    --with-http_auth_request_module \
    --with-compat \
	--with-http_geoip_module \
    --with-http_image_filter_module \
	--with-mail \
    --with-mail_ssl_module \
    --with-google_perftools_module \
	--with-debug \
    --with-pcre-jit \
    --with-ipv6 \
    --with-http_stub_status_module \
    --with-http_realip_module \
	--with-http_addition_module \
    --with-http_gzip_static_module \
    --with-http_sub_module \
    --with-stream \
    --with-stream_geoip_module \
    --with-stream_realip_module \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --with-http_random_index_module \
    --with-http_gunzip_module \
    --with-http_v2_module \
    --with-http_slice_module \
	--add-module=/usr/src/nginx-rtmp-module \
	--add-module=/usr/src/ngx_devel_kit \
	--add-module=/usr/src/lua-nginx-module \
	--add-module=/usr/src/echo-nginx-module \
	--add-module=/usr/src/nginx-ts-module \
    --add-module=/usr/src/nginx-module-vts \
    --add-module=/usr/src/nginx-module-stream-sts \
    --add-module=/usr/src/nginx-module-sts \
    --add-module=/usr/src/naxsi/naxsi_src \
    --add-module=/usr/src/nginx-vod-module \
    --add-module=/usr/src/njs/nginx \
    --add-module=/usr/src/ModSecurity-nginx \
    --add-module=/usr/src/headers-more-nginx-module \
    --add-module=/usr/src/ngx_http_dyups_module \
    --add-module=/usr/src/lua-upstream-nginx-module \
    --add-module=/usr/src/nginx_upstream_check_module \
    --add-module=/usr/src/nginx-sticky-module-ng \
    --add-module=/usr/src/status-nginx-module \
    && make -j$(nproc) \
    && make install \
    && cp -rf /usr/src/lua-resty-core/lib/* /usr/local/share/lua/5.1/ \
    && cp -rf /usr/src/lua-resty-lrucache/lib/* /usr/local/share/lua/5.1/ \
    && rm -rf /usr/src/* 

EXPOSE 80
EXPOSE 1935
EXPOSE 443
EXPOSE 22

VOLUME /usr/local/nginx/conf
VOLUME /usr/local/nginx/html
VOLUME /usr/local/nginx/lua
VOLUME /usr/local/nginx/logs
VOLUME /usr/local/nginx/cache

#COPY
ADD . /scripts 

CMD ["/scripts/run.sh"]

RUN chmod +x /scripts/run.sh

