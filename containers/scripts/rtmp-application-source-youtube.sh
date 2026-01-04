#!/bin/sh

. /srv/scripts/rtmp-common-init.sh

SOURCE_URL="$1"
SOURCE_COOKIES="$RTMP_APPLICATION_YOUTUBE_COOKIES_FILE"

get_stream_source() {
#  yt-dlp \
  yt-dlp --quiet --no-progress --no-warnings \
      --cookies "${SOURCE_COOKIES}" \
      -o - "${SOURCE_URL}"
#      --js-runtimes node \
#      -f "91/92/93/best" \
}

set_stream_source() {
#  ffmpeg -loglevel error -hide_banner \
#      -analyzeduration 10M -probesize 10M \
#      -thread_queue_size 4096 \
#      -i pipe:0 \
#      -map 0:a \
#      -vn \
#      -c:a aac -b:a 128k -ar 44100 \
#      -f flv "rtmp://localhost:1935/$MTX_PATH?user=${RTMP_APPLICATION_USERNAME}&pass=${RTMP_APPLICATION_PASSWORD}"
# --------------------------------------------
#  ffmpeg -loglevel error -hide_banner \
#  ffmpeg -loglevel info -hide_banner \
#    -reconnect 1 -reconnect_at_eof 1 -reconnect_streamed 1 -reconnect_delay_max 5 \
  ffmpeg \
    -thread_queue_size 4096 \
    -i pipe:0 \
    -c:v copy \
    -c:a copy \
    -f flv \
      "rtmp://localhost:1935/$MTX_PATH?user=${RTMP_APPLICATION_USERNAME}&pass=${RTMP_APPLICATION_PASSWORD}"
}

set -x
get_stream_source | set_stream_source