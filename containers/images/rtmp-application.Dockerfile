FROM bluenviron/mediamtx:1.15.6-ffmpeg

USER root

#RUN apt-get update && apt-get install -y --no-install-recommends \
#    python3 \
#    python3-pip \
#    ca-certificates \
#    curl \
# && apt-get clean \
# && rm -rf /var/lib/apt/lists/*

RUN apk add --no-cache \
    python3 \
    py3-pip \
    ca-certificates \
    curl \
    nodejs

RUN pip3 install --no-cache-dir --break-system-packages yt-dlp

ENTRYPOINT [ "/entrypoint.sh" ]