FROM ubuntu:16.04 as base
#FROM ubuntu-nginx-aptget-install-req
ENV DEBIAN_FRONTEND noninteractive
ENV TZ=Europe/Kiev
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y -qy --no-install-recommends --no-install-suggests \
	software-properties-common \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /usr/share/doc/* \
    && rm -rf /usr/share/man/* \
    && apt-get autoremove -y \
    && apt-get clean -y

FROM base AS prebuild  
RUN apt-get -yqq update \
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
    gettext gnupg2 curl python3 jq ca-certificates gcc g++ gperf \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /usr/share/doc/* \
    && rm -rf /usr/share/man/* \
    && apt-get autoremove -y \
    && apt-get clean -y

FROM prebuild AS build
ARG        PKG_CONFIG_PATH=/opt/ffmpeg/lib/pkgconfig
ARG        LD_LIBRARY_PATH=/opt/ffmpeg/lib
ARG        PREFIX=/usr/ffmpeg_build

ENV         FFMPEG_VERSION=3.3.9     \
            FDKAAC_VERSION=0.1.5      \
            LAME_VERSION=3.100        \
            LIBASS_VERSION=0.13.7     \
            OGG_VERSION=1.3.2         \
            OPENCOREAMR_VERSION=0.1.5 \
            OPUS_VERSION=1.2          \
            OPENJPEG_VERSION=2.1.2    \
            THEORA_VERSION=1.1.1      \
            VORBIS_VERSION=1.3.5      \
            VPX_VERSION=1.8.0         \
            WEBP_VERSION=1.0.2        \
            X264_VERSION=20170226-2245-stable \
            X265_VERSION=2.3          \
            XVID_VERSION=1.3.4        \
            FREETYPE_VERSION=2.5.5    \
            FRIBIDI_VERSION=0.19.7    \
            FONTCONFIG_VERSION=2.12.4 \
            LIBVIDSTAB_VERSION=1.1.0  \
            KVAZAAR_VERSION=1.2.0     \
            AOM_VERSION=v1.0.0        \
            SRC=/usr/local
## opencore-amr https://sourceforge.net/projects/opencore-amr/
RUN echo "Compiling opencore-amr" \
    && mkdir -p /usr/src/ffmpeg_sources /usr/src/bin \
    && cd /usr/src/ffmpeg_sources \
    && wget https://kent.dl.sourceforge.net/project/opencore-amr/opencore-amr/opencore-amr-${OPENCOREAMR_VERSION}.tar.gz \
    && tar -xzf opencore-amr-${OPENCOREAMR_VERSION}.tar.gz \
    && cd opencore-amr-${OPENCOREAMR_VERSION} \
    && ./configure --enable-shared \
    && make -j$(nproc) \
    && make install 

## Compiling nasm
RUN echo "Compiling nasm" \
    && mkdir -p /usr/src/ffmpeg_sources /usr/src/bin \
    && cd /usr/src/ffmpeg_sources \
    && wget http://www.nasm.us/pub/nasm/releasebuilds/2.13.03/nasm-2.13.03.tar.bz2 \
    && tar xjvf nasm-2.13.03.tar.bz2 \
    && cd nasm-2.13.03 \
    && ./autogen.sh \
    && PATH="/usr/bin:$PATH" ./configure --bindir="/usr/bin" \
    && make -j$(nproc) \
    && make install

## Compiling yasm
RUN echo "Compiling yasm" \
    && cd /usr/src/ffmpeg_sources \
    && wget -O yasm-1.3.0.tar.gz http://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz \
    && tar xzvf yasm-1.3.0.tar.gz \
    && cd yasm-1.3.0 \
    && ./configure --bindir="/usr/bin" \
    && make -j$(nproc) \
    && make install

## x264 http://www.videolan.org/developers/x264.html
RUN echo "Compiling x264" \
    && cd /usr/src/ffmpeg_sources \
    && git -C x264 pull 2> /dev/null || git clone --depth 1 https://code.videolan.org/videolan/x264 \
    && cd x264 \
    && PATH="/usr/bin:$PATH" PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig" ./configure --bindir="/usr/bin" --enable-static \
    && PATH="/usr/bin:$PATH" make -j$(nproc) \
    && make install

### x265 http://x265.org/
RUN echo "Compiling x265" \
    && cd /usr/src/ffmpeg_sources \
    && if cd x265 2> /dev/null; then hg pull \
    && hg update; else hg clone https://bitbucket.org/multicoreware/x265; fi \
    && cd x265/build/linux \
    && PATH="/usr/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DENABLE_SHARED:bool=off ../../source \
    && PATH="/usr/bin:$PATH" make -j$(nproc) \
    && make install

### libogg https://www.xiph.org/ogg/
RUN cd /usr/src/ffmpeg_sources \
    && wget http://downloads.xiph.org/releases/ogg/libogg-${OGG_VERSION}.tar.gz \
    && tar -xzf libogg-${OGG_VERSION}.tar.gz \
    && cd libogg-${OGG_VERSION} \
    && ./configure --enable-shared \
    && make -j$(nproc) \
    && make install 

### libvorbis https://xiph.org/vorbis/
RUN cd /usr/src/ffmpeg_sources \
    && wget http://downloads.xiph.org/releases/vorbis/libvorbis-${VORBIS_VERSION}.tar.gz \
    && tar -xzf libvorbis-${VORBIS_VERSION}.tar.gz \
    && cd libvorbis-${VORBIS_VERSION} \
    && ./configure --with-ogg="${PREFIX}" --enable-shared \
    && make -j$(nproc) \
    && make install 
    
### libtheora http://www.theora.org/
RUN cd /usr/src/ffmpeg_sources \
    && wget http://downloads.xiph.org/releases/theora/libtheora-${THEORA_VERSION}.tar.gz \
    && tar -xzf libtheora-${THEORA_VERSION}.tar.gz \
    && cd libtheora-${THEORA_VERSION} \
    && ./configure --with-ogg="${PREFIX}" --enable-shared \
    && make -j$(nproc) \
    && make install 

### libvpx https://www.webmproject.org/code/
RUN echo "Compiling libvpx" \
    && cd /usr/src/ffmpeg_sources \
    && git -C libvpx pull 2> /dev/null || git clone --depth 1 https://chromium.googlesource.com/webm/libvpx.git \
    && cd libvpx \
    && PATH="/usr/bin:$PATH" ./configure --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --as=yasm \
    && PATH="/usr/bin:$PATH" make -j$(nproc) \
    && make install 

RUN echo "Compiling fdkaac" \
    && cd /usr/src/ffmpeg_sources \
    && git -C fdk-aac pull 2> /dev/null || git clone --depth 1 https://github.com/mstorsjo/fdk-aac \
    && cd fdk-aac \
    && autoreconf -fiv \
    && ./configure --disable-shared \
    && make -j$(nproc) \
    && make install

### libwebp https://developers.google.com/speed/webp/
RUN cd /usr/src/ffmpeg_sources \
    && wget https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-${WEBP_VERSION}.tar.gz \
    && tar -xzf libwebp-${WEBP_VERSION}.tar.gz \
    && cd libwebp-${WEBP_VERSION} \
    && ./configure --enable-shared \
    && make -j$(nproc) \
    && make install 

### libmp3lame http://lame.sourceforge.net/
RUN echo "Compiling lame" \
    && cd /usr/src/ffmpeg_sources \
    && wget -O lame-3.100.tar.gz http://downloads.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz \
    && tar xzvf lame-3.100.tar.gz \
    && cd lame-3.100 \
    && PATH="/usr/bin:$PATH" ./configure --bindir="/usr/bin" --disable-shared --enable-nasm \
    && PATH="/usr/bin:$PATH" make -j$(nproc) \
    && make install 

### libopus https://www.opus-codec.org/
RUN echo "Compiling opus" \
    && cd /usr/src/ffmpeg_sources \
    && git -C opus pull 2> /dev/null || git clone --depth 1 https://github.com/xiph/opus.git \
    && cd opus \
    && ./autogen.sh \
    && ./configure --disable-shared \
    && make -j$(nproc) \
    && make install 

RUN echo "Compiling aom" \
    && cd /usr/src/ffmpeg_sources \
    && git -C aom pull 2> /dev/null || git clone --depth 1 https://aomedia.googlesource.com/aom \
    && mkdir -p aom_build \
    && cd aom_build \
    && PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DENABLE_SHARED=off -DENABLE_NASM=on ../aom \
    && PATH="$HOME/bin:$PATH" make  -j$(nproc) \
    && make install 

### xvid https://www.xvid.com/
RUN cd /usr/src/ffmpeg_sources \
    && wget http://downloads.xvid.org/downloads/xvidcore-${XVID_VERSION}.tar.gz \
    && tar -xzf xvidcore-${XVID_VERSION}.tar.gz \
    && cd xvidcore/build/generic \
    && ./configure --bindir="${PREFIX}/bin" --datadir="${PREFIX}" --enable-shared --enable-shared \
    && make -j$(nproc) \
    && make install

## openjpeg https://github.com/uclouvain/openjpeg
RUN cd /usr/src/ffmpeg_sources \
    && wget https://github.com/uclouvain/openjpeg/archive/v${OPENJPEG_VERSION}.tar.gz \
    && tar -xzf v${OPENJPEG_VERSION}.tar.gz \
    && cd openjpeg-${OPENJPEG_VERSION} \
    && cmake -DBUILD_THIRDPARTY:BOOL=ON . \
    && make -j$(nproc) \
    && make install 

## freetype https://www.freetype.org/
RUN  \
        DIR=/tmp/freetype && \
        mkdir -p ${DIR} && \
        cd ${DIR} && \
        curl -sLO https://download.savannah.gnu.org/releases/freetype/freetype-${FREETYPE_VERSION}.tar.gz && \
        tar -zx --strip-components=1 -f freetype-${FREETYPE_VERSION}.tar.gz && \
        ./configure --disable-static --enable-shared && \
        make && \
        make install && \
        rm -rf ${DIR}
## libvstab https://github.com/georgmartius/vid.stab
RUN  \
        DIR=/tmp/vid.stab && \
        mkdir -p ${DIR} && \
        cd ${DIR} && \
        curl -sLO https://github.com/georgmartius/vid.stab/archive/v${LIBVIDSTAB_VERSION}.tar.gz &&\
        tar -zx --strip-components=1 -f v${LIBVIDSTAB_VERSION}.tar.gz && \
        cmake . && \
        make && \
        make install && \
        rm -rf ${DIR}
## fridibi https://www.fribidi.org/
# + https://github.com/fribidi/fribidi/issues/8
RUN  \
        DIR=/tmp/fribidi && \
        mkdir -p ${DIR} && \
        cd ${DIR} && \
        curl -sLO https://github.com/fribidi/fribidi/archive/${FRIBIDI_VERSION}.tar.gz && \
        tar -zx --strip-components=1 -f ${FRIBIDI_VERSION}.tar.gz && \
        sed -i 's/^SUBDIRS =.*/SUBDIRS=gen.tab charset lib/' Makefile.am && \
        ./bootstrap --no-config && \
        ./configure   --disable-static --enable-shared && \
        make -j 1 && \
        make install && \
        rm -rf ${DIR}
## fontconfig https://www.freedesktop.org/wiki/Software/fontconfig/
RUN  \
        DIR=/tmp/fontconfig && \
        mkdir -p ${DIR} && \
        cd ${DIR} && \
        curl -sLO https://www.freedesktop.org/software/fontconfig/release/fontconfig-${FONTCONFIG_VERSION}.tar.bz2 &&\
        tar -jx --strip-components=1 -f fontconfig-${FONTCONFIG_VERSION}.tar.bz2 && \
        ./configure   --disable-static --enable-shared && \
        make && \
        make install && \
        rm -rf ${DIR}
## libass https://github.com/libass/libass
RUN  \
        DIR=/tmp/libass && \
        mkdir -p ${DIR} && \
        cd ${DIR} && \
        curl -sLO https://github.com/libass/libass/archive/${LIBASS_VERSION}.tar.gz &&\
        tar -zx --strip-components=1 -f ${LIBASS_VERSION}.tar.gz && \
        ./autogen.sh && \
        ./configure   --disable-static --enable-shared && \
        make && \
        make install && \
        rm -rf ${DIR}
## kvazaar https://github.com/ultravideo/kvazaar
RUN \
        DIR=/tmp/kvazaar && \
        mkdir -p ${DIR} && \
        cd ${DIR} && \
        curl -sLO https://github.com/ultravideo/kvazaar/archive/v${KVAZAAR_VERSION}.tar.gz &&\
        tar -zx --strip-components=1 -f v${KVAZAAR_VERSION}.tar.gz && \
        ./autogen.sh && \
        ./configure   --disable-static --enable-shared && \
        make && \
        make install && \
        rm -rf ${DIR}

RUN echo "Compiling ffmpeg" \
    && cd /usr/src/ffmpeg_sources \
    && git clone https://git.ffmpeg.org/ffmpeg.git ffmpeg \
    && cd ffmpeg \
    && PATH="/usr/bin:$PATH" PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig" ./configure \
    --prefix="${PREFIX}" \
    --pkg-config-flags="--static" \
    --extra-cflags="-I/usr/ffmpeg_build/include" \
    --extra-ldflags="-L/usr/ffmpeg_build/lib" \
    --extra-libs="-lpthread -lm -ldl" \
    --bindir="/usr/bin" \
    --disable-doc \
    --disable-ffplay \
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
    \
    --enable-avresample \
    --enable-libopencore-amrnb \
    --enable-libopencore-amrwb \
    --enable-libass \
    --enable-libvidstab \
    --enable-libopenjpeg \
    --enable-libwebp \
    --enable-libxvid \
    --enable-openssl \
    --enable-libkvazaar \
    \
    --enable-postproc \
    --enable-small \
    --enable-version3 \
    && PATH="/usr/bin:$PATH" make -j$(nproc) \
    && make install
RUN find / -name ffmpeg \
    && cp /usr/bin/ffmpeg /usr/local/bin/ffmpeg \
    && hash -r \
    && cd /usr/src/ffmpeg_sources/ffmpeg/tools \
    && make qt-faststart \
    && cp qt-faststart ${PREFIX}/bin \
    && rm -rf /usr/src/*

## cleanup
RUN LD_LIBRARY_PATH=/usr/local/lib ldd /usr/bin/ffmpeg | grep -v '/usr/local/lib' | cut -d ' ' -f 3 | xargs -i cp {} /usr/local/lib/ \
    && cp -r ${PREFIX}/share/ffmpeg /usr/local/share/ \
    && LD_LIBRARY_PATH=/usr/local/lib ffmpeg -buildconf

FROM        base AS release
LABEL maintainer="Dmytro Burianov <dmytro@burianov.net>"

COPY --from=build /usr/local /usr/local/

#RUN echo $PATH
#RUN ls -la  /usr/local/bin /usr/bin
#RUN LD_LIBRARY_PATH=/usr/local/lib /usr/local/bin/ffmpeg --help
RUN ldconfig /usr/local/lib
RUN ffmpeg --help

CMD         ["--help"]
ENTRYPOINT  ["ffmpeg"]
ENV         LD_LIBRARY_PATH=/usr/local/lib

#COPY --from=build /usr/local /usr/local/

