FROM ubuntu:16.04
#FROM ubuntu-nginx-aptget-install-req
ENV DEBIAN_FRONTEND noninteractive

ENV TZ=Europe/Kiev
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
	software-properties-common git unzip libxml2-dev \
	libbz2-dev libcurl4-openssl-dev libmcrypt-dev libmhash2 \
	libmhash-dev libpcre3 libpcre3-dev make build-essential \
	libxslt1-dev libgd2-xpm-dev libgeoip-dev \
	libpam-dev libgoogle-perftools-dev lua5.1 liblua5.1-0 \
	liblua5.1-0-dev checkinstall wget libssl-dev \
    mercurial meld \
    autoconf automake cmake libass-dev libfreetype6-dev \
    libsdl2-dev libtheora-dev libtool libva-dev libvdpau-dev \
    libvorbis-dev libxcb1-dev libxcb-shm0-dev libxcb-xfixes0-dev \
    pkg-config texinfo zlib1g-dev \

    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /usr/share/doc/* \
    && rm -rf /usr/share/man/* \

    && git clone http://luajit.org/git/luajit-2.0.git /usr/src/luajit-2.0 \
    && git clone https://github.com/simpl/ngx_devel_kit.git /usr/src/ngx_devel_kit \
    && git clone https://github.com/openresty/lua-nginx-module.git /usr/src/lua-nginx-module \
    && git clone https://github.com/openresty/echo-nginx-module.git /usr/src/echo-nginx-module \
    && git clone git://github.com/vozlt/nginx-module-vts.git /usr/src/nginx-module-vts \
    && git clone https://github.com/nbs-system/naxsi.git /usr/src/naxsi \
    && git clone https://github.com/kaltura/nginx-vod-module.git /usr/src/nginx-vod-module \
    && git clone https://github.com/arut/nginx-rtmp-module.git /usr/src/nginx-rtmp-module \
    && git clone https://github.com/arut/nginx-ts-module.git /usr/src/nginx-ts-module \

    && cd /usr/src/luajit-2.0 && make -j$(nproc) && make install && cd .. \
    && export LUAJIT_LIB=/usr/local/lib \
    && export LUAJIT_INC=/usr/local/include/luajit-2.0 \

    && ldconfig \

    && cd /usr/src/ && hg clone http://hg.nginx.org/nginx \
    && cd /usr/src/nginx && cp ./auto/configure . && ./configure \
    --with-http_xslt_module --with-http_ssl_module --with-http_mp4_module --with-http_flv_module \
	--with-http_secure_link_module --with-http_dav_module \
	--with-http_geoip_module --with-http_image_filter_module \
	--with-mail --with-mail_ssl_module --with-google_perftools_module \
	--with-debug --with-pcre-jit --with-ipv6 --with-http_stub_status_module --with-http_realip_module \
	--with-http_addition_module --with-http_gzip_static_module --with-http_sub_module \
    --with-stream --with-http_v2_module \
	--add-module=/usr/src/nginx-rtmp-module \
	--add-module=/usr/src/ngx_devel_kit \
	--add-module=/usr/src/lua-nginx-module \
	--add-module=/usr/src/echo-nginx-module \
	--add-module=/usr/src/nginx-ts-module \
    --add-module=/usr/src/nginx-module-vts \
    --add-module=/usr/src/naxsi/naxsi_src \
    --add-module=/usr/src/nginx-vod-module \
    && make -j$(nproc) && make install \
    && rm -rf /usr/src/* \

    && mkdir -p /usr/src/ffmpeg_sources /usr/src/bin \
    && cd /usr/src/ffmpeg_sources \
    && wget http://www.nasm.us/pub/nasm/releasebuilds/2.13.02/nasm-2.13.02.tar.bz2 \
    && tar xjvf nasm-2.13.02.tar.bz2 \
    && cd nasm-2.13.02 \
    && ./autogen.sh \
    && PATH="/usr/bin:$PATH" ./configure --prefix="/usr/ffmpeg_build" --bindir="/usr/bin" \
    && make -j$(nproc) && make install \

    && rm -rf /usr/src/ffmpeg_sources/* \

    && cd /usr/src/ffmpeg_sources \
    && wget -O yasm-1.3.0.tar.gz http://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz \
    && tar xzvf yasm-1.3.0.tar.gz \
    && cd yasm-1.3.0 \
    && ./configure --prefix="/usr/ffmpeg_build" --bindir="/usr/bin" \
    && make -j$(nproc) && make install \

    && rm -rf /usr/src/ffmpeg_sources/* \

    && cd /usr/src/ffmpeg_sources \
    && git -C x264 pull 2> /dev/null || git clone --depth 1 http://git.videolan.org/git/x264 \
    && cd x264 \
    && PATH="/usr/bin:$PATH" PKG_CONFIG_PATH="/usr/ffmpeg_build/lib/pkgconfig" ./configure --prefix="/usr/ffmpeg_build" --bindir="/usr/bin" --enable-static \
    && PATH="/usr.bin:$PATH" make -j$(nproc) && make install \

    && rm -rf /usr/src/ffmpeg_sources/* \

    && cd /usr/src/ffmpeg_sources \
    && if cd x265 2> /dev/null; then hg pull && hg update; else hg clone https://bitbucket.org/multicoreware/x265; fi \
    && cd x265/build/linux \
    && PATH="/usr/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="/usr/ffmpeg_build" -DENABLE_SHARED:bool=off ../../source \
    && PATH="/usr/bin:$PATH" make -j$(nproc) && make install \

    && rm -rf /usr/src/ffmpeg_sources/* \

    && cd /usr/src/ffmpeg_sources \
    && git -C libvpx pull 2> /dev/null || git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git \
    && cd libvpx \
    && PATH="/usr/bin:$PATH" ./configure --prefix="/usr/ffmpeg_build" --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --as=yasm \
    && PATH="/usr/bin:$PATH" make -j$(nproc) && make install \

    && rm -rf /usr/src/ffmpeg_sources/* \

    && cd /usr/src/ffmpeg_sources \
    && git -C fdk-aac pull 2> /dev/null || git clone --depth 1 https://github.com/mstorsjo/fdk-aac \
    && cd fdk-aac \
    && autoreconf -fiv \
    && ./configure --prefix="/usr/ffmpeg_build" --disable-shared \
    && make -j$(nproc) && make install \

    && rm -rf /usr/src/ffmpeg_sources/* \

    && cd /usr/src/ffmpeg_sources \
    && wget -O lame-3.100.tar.gz http://downloads.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz \
    && tar xzvf lame-3.100.tar.gz \
    && cd lame-3.100 \
    && PATH="/usr/bin:$PATH" ./configure --prefix="/usr/ffmpeg_build" --bindir="/usr/bin" --disable-shared --enable-nasm \
    && PATH="/usr/bin:$PATH" make -j$(nproc) && make install \

    && rm -rf /usr/src/ffmpeg_sources/* \

    && cd /usr/src/ffmpeg_sources \
    && git -C opus pull 2> /dev/null || git clone --depth 1 https://github.com/xiph/opus.git \
    && cd opus \
    && ./autogen.sh \
    && ./configure --prefix="/usr/ffmpeg_build" --disable-shared \
    && make -j$(nproc) && make install \

    && rm -rf /usr/src/ffmpeg_sources/* \

    && cd /usr/src/ffmpeg_sources \
    && wget -O ffmpeg-3.4.2.tar.bz2 http://ffmpeg.org/releases/ffmpeg-3.4.2.tar.bz2 \
    && tar xjvf ffmpeg-3.4.2.tar.bz2 \
    && cd ffmpeg-3.4.2 \
    && PATH="/usr/bin:$PATH" PKG_CONFIG_PATH="/usr/ffmpeg_build/lib/pkgconfig" ./configure \
    --prefix="/usr/ffmpeg_build" \
    --pkg-config-flags="--static" \
    --extra-cflags="-I/usr/ffmpeg_build/include" \
    --extra-ldflags="-L/usr/ffmpeg_build/lib" \
    --extra-libs="-lpthread -lm" \
    --bindir="/usr/bin" \
    --enable-gpl \
    --enable-libass \
    --enable-libfdk-aac \
    --enable-libfreetype \
    --enable-libmp3lame \
    --enable-libopus \
    --enable-libtheora \
    --enable-libvorbis \
    --enable-libvpx \
    --enable-libx264 \
    --enable-libx265 \
    --enable-nonfree \
    --enable-filter=movie --enable-filter=drawtext --enable-libfreetype --enable-filter=overlay --enable-filter=yadif \
    && PATH="/usr/bin:$PATH" make -j$(nproc) && make install \
    && ls -s /usr/bin/ffmpeg /usr/local/bin/ffmpeg && ls -s /usr/bin/ffprob /usr/local/bin/ffprob \
    && hash -r \

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

