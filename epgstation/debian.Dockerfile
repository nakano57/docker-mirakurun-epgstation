FROM l3tnun/epgstation:master-debian

ENV DEV="make gcc git g++ automake curl wget autoconf build-essential libass-dev libfreetype6-dev libsdl1.2-dev libtheora-dev libtool libva-dev libvdpau-dev libvorbis-dev libxcb1-dev libxcb-shm0-dev libxcb-xfixes0-dev pkg-config texinfo zlib1g-dev"
ENV FFMPEG_VERSION=6.1

RUN sed -i "s/Components: main/Components: main contrib non-free/" /etc/apt/sources.list.d/debian.sources  && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y $DEV && \
    apt-get install -y yasm libx264-dev libmp3lame-dev libopus-dev libvpx-dev libcrypt1 libpam-runtime libpam-modules && \
    apt-get install -y libx265-dev libnuma-dev && \
    apt-get install -y libasound2 libass9 libvdpau1 libva-x11-2 libva-drm2 libxcb-shm0 libxcb-xfixes0 libxcb-shape0 libvorbisenc2 libtheora0 libaribb24-dev && \
    apt-get -y install i965-va-driver-shaders libva-dev libmfx-dev intel-media-va-driver-non-free vainfo

#ffmpeg cinfigure
RUN mkdir /tmp/ffmpeg_sources && \
    cd /tmp/ffmpeg_sources && \
    curl -fsSL http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.bz2 | tar -xj --strip-components=1 && \
    ./configure \
      --prefix=/usr/local \
      --disable-shared \
      --enable-static \
      --enable-gpl \
      --enable-libass \
      --enable-libfreetype \
      --enable-libmp3lame \
      --enable-libopus \
      --enable-libtheora \
      --enable-libvorbis \
      --enable-libvpx \
      --enable-libx264 \
      --enable-libx265 \
      --enable-version3 \
      --enable-libaribb24 \
      --enable-nonfree \
      --disable-debug \
      --disable-doc \
      --enable-libmfx 

#ffmpeg build
WORKDIR /tmp/ffmpeg_sources
RUN make -j$(nproc) && \
    make install 

# 不要なパッケージを削除
WORKDIR /app
RUN apt-get -y remove $DEV && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*