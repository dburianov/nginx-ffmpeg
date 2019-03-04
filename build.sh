#!/bin/bash

original_pwd=$(pwd)
TZ=Europe/Kiev
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime 
echo $TZ > /etc/timezone

apt-get update
apt-get upgrade -y
apt-get install -y --no-install-recommends \
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
    pkg-config texinfo zlib1g-dev pkgconf libyajl-dev libpcre++-dev liblmdb-dev

git clone http://luajit.org/git/luajit-2.0.git /usr/src/luajit-2.0 
git clone https://github.com/simpl/ngx_devel_kit.git /usr/src/ngx_devel_kit 
git clone https://github.com/openresty/lua-nginx-module.git /usr/src/lua-nginx-module 
git clone https://github.com/openresty/echo-nginx-module.git /usr/src/echo-nginx-module 
git clone https://github.com/vozlt/nginx-module-vts.git /usr/src/nginx-module-vts 
git clone https://github.com/vozlt/nginx-module-stream-sts.git /usr/src/nginx-module-stream-sts 
git clone https://github.com/vozlt/nginx-module-sts.git /usr/src/nginx-module-sts 
git clone https://github.com/nbs-system/naxsi.git /usr/src/naxsi 
git clone https://github.com/kaltura/nginx-vod-module.git /usr/src/nginx-vod-module 
git clone https://github.com/arut/nginx-rtmp-module.git /usr/src/nginx-rtmp-module 
git clone https://github.com/arut/nginx-ts-module.git /usr/src/nginx-ts-module 
git clone https://github.com/openresty/headers-more-nginx-module.git /usr/src/headers-more-nginx-module 
git clone https://github.com/yzprofile/ngx_http_dyups_module.git /usr/src/ngx_http_dyups_module 
git clone https://github.com/openresty/lua-upstream-nginx-module.git /usr/src/lua-upstream-nginx-module 
git clone https://github.com/dburianov/nginx_upstream_check_module.git /usr/src/nginx_upstream_check_module
git clone https://bitbucket.org/nginx-goodies/nginx-sticky-module-ng.git /usr/src/nginx-sticky-module-ng

cd /usr/src/luajit-2.0 
make -j$(nproc) 
make install 
cd .. 
export LUAJIT_LIB=/usr/local/lib 
export LUAJIT_INC=/usr/local/include/luajit-2.0 
ldconfig 
echo "Compiling ModSecurity" 
cd /usr/src 
git clone --depth 1 -b v3/master --single-branch https://github.com/SpiderLabs/ModSecurity 
cd ModSecurity 
git submodule init 
git submodule update 
./build.sh 
./configure 
make -j$(nproc) 
make install 
cd /usr/src 
git clone --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx.git 
echo "Compiling Nginx" 
cd /usr/src/ 
hg clone http://hg.nginx.org/nginx 
hg clone http://hg.nginx.org/njs 
cd /usr/src/nginx 
#patch -p1 < $original_pwd/check_1.15.patch
#patch -p1 < /usr/src/nginx_upstream_check_module/check.patch
patch -d/ -p0 < $original_pwd/1.diff
patch -d/ -p0 < $original_pwd/2.diff
patch -d/ -p0 < $original_pwd/3.diff
patch -d/ -p0 < $original_pwd/4.diff
patch -d/ -p0 < $original_pwd/5.diff
#exit 1
cp ./auto/configure . 
./configure \
    --with-http_xslt_module \
    --with-http_ssl_module \
    --with-http_mp4_module \
    --with-http_flv_module \
    --with-http_secure_link_module \
    --with-http_dav_module \
    --with-http_auth_request_module \
    --with-http_geoip_module \
    --with-http_image_filter_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-google_perftools_module \
    --with-debug \
    --with-pcre-jit \
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
    --add-module=/usr/src/nginx-sticky-module-ng

make -j$(nproc) 
make install 

exit 0

echo "Compiling nasm" 
mkdir -p /usr/src/ffmpeg_sources /usr/src/bin 
cd /usr/src/ffmpeg_sources 
wget http://www.nasm.us/pub/nasm/releasebuilds/2.13.02/nasm-2.13.02.tar.bz2 
tar xjvf nasm-2.13.02.tar.bz2 
cd nasm-2.13.02 
./autogen.sh 
PATH="/usr/bin:$PATH" ./configure --prefix="/usr/ffmpeg_build" --bindir="/usr/bin" 
make -j$(nproc) 
make install 

echo "Compiling yasm" 
cd /usr/src/ffmpeg_sources 
wget -O yasm-1.3.0.tar.gz http://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz 
tar xzvf yasm-1.3.0.tar.gz 
cd yasm-1.3.0 
./configure --prefix="/usr/ffmpeg_build" --bindir="/usr/bin" 
make -j$(nproc) 
make install 

echo "Compiling x264" 
cd /usr/src/ffmpeg_sources 
git -C x264 pull 2> /dev/null || git clone --depth 1 http://git.videolan.org/git/x264 
cd x264 
PATH="/usr/bin:$PATH" PKG_CONFIG_PATH="/usr/ffmpeg_build/lib/pkgconfig" ./configure --prefix="/usr/ffmpeg_build" --bindir="/usr/bin" --enable-static 
PATH="/usr/bin:$PATH" make -j$(nproc) 
make install 

echo "Compiling x265" 
cd /usr/src/ffmpeg_sources 
if cd x265 2> /dev/null; then hg pull 
hg update; else hg clone https://bitbucket.org/multicoreware/x265; fi 
cd x265/build/linux 
PATH="/usr/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="/usr/ffmpeg_build" -DENABLE_SHARED:bool=off ../../source 
PATH="/usr/bin:$PATH" make -j$(nproc) 
make install 

echo "Compiling libvpx" 
cd /usr/src/ffmpeg_sources 
git -C libvpx pull 2> /dev/null || git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git 
cd libvpx 
PATH="/usr/bin:$PATH" ./configure --prefix="/usr/ffmpeg_build" --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --as=yasm 
PATH="/usr/bin:$PATH" make -j$(nproc) 
make install 

echo "Compiling fdkaac" 
cd /usr/src/ffmpeg_sources 
git -C fdk-aac pull 2> /dev/null || git clone --depth 1 https://github.com/mstorsjo/fdk-aac 
cd fdk-aac 
autoreconf -fiv 
./configure --prefix="/usr/ffmpeg_build" --disable-shared 
make -j$(nproc) 
make install 

echo "Compiling lame" 
cd /usr/src/ffmpeg_sources 
wget -O lame-3.100.tar.gz http://downloads.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz 
tar xzvf lame-3.100.tar.gz 
cd lame-3.100 
PATH="/usr/bin:$PATH" ./configure --prefix="/usr/ffmpeg_build" --bindir="/usr/bin" --disable-shared --enable-nasm 
PATH="/usr/bin:$PATH" make -j$(nproc) 
make install 

echo "Compiling opus" 
cd /usr/src/ffmpeg_sources 
git -C opus pull 2> /dev/null || git clone --depth 1 https://github.com/xiph/opus.git 
cd opus 
./autogen.sh 
./configure --prefix="/usr/ffmpeg_build" --disable-shared 
make -j$(nproc) 
make install 

echo "Compiling aom"
cd ~/ffmpeg_sources && \
git -C aom pull 2> /dev/null || git clone --depth 1 https://aomedia.googlesource.com/aom && \
mkdir -p aom_build && \
cd aom_build && \
PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="/usr/ffmpeg_build" -DENABLE_SHARED=off -DENABLE_NASM=on ../aom && \
PATH="$HOME/bin:$PATH" make  -j$(nproc) && \
make install

echo "Compiling ffmpeg" 
cd /usr/src/ffmpeg_sources 
#wget -O ffmpeg-3.4.2.tar.bz2 http://ffmpeg.org/releases/ffmpeg-3.4.2.tar.bz2 
#tar xjvf ffmpeg-3.4.2.tar.bz2 
#cd ffmpeg-3.4.2 
git clone https://git.ffmpeg.org/ffmpeg.git ffmpeg 
cd ffmpeg 
PATH="/usr/bin:$PATH" PKG_CONFIG_PATH="/usr/ffmpeg_build/lib/pkgconfig" ./configure \
    --prefix="/usr/ffmpeg_build" \
    --pkg-config-flags="--static" \
    --extra-cflags="-I/usr/ffmpeg_build/include" \
    --extra-ldflags="-L/usr/ffmpeg_build/lib" \
    --extra-libs="-lpthread -lm" \
    --bindir="/usr/bin" \
    --enable-gpl \
    --enable-libaom \
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
    --enable-libxcb \
    --enable-libpulse \
    --enable-alsa \
    --enable-filter=movie \
    --enable-filter=drawtext \
    --enable-libfreetype \
    --enable-filter=overlay \
    --enable-filter=yadif \
PATH="/usr/bin:$PATH" make -j$(nproc)
make install 
#ln -s /usr/bin/ffmpeg /usr/local/bin/ffmpeg && ln -s /usr/bin/ffprob /usr/local/bin/ffprob 
hash -r 
