#!/bin/sh

. /srv/scripts/rtmp-common-init.sh

SOURCE_URL="$1"
SOURCE_COOKIES="$RTMP_APPLICATION_YOUTUBE_COOKIES_FILE"

get_stream_source() {
  STREAM_QUALITY_BEST="best"
  STREAM_QUALITY_720p60fps="best[height<=720][fps<=30]/bestvideo[height<=720][fps<=30]+bestaudio/best"

#  yt-dlp \
  yt-dlp --quiet --no-progress --no-warnings \
    -f "${STREAM_QUALITY_720p60fps}" \
    -o - "${SOURCE_URL}"
}

set_stream_source() {
#  ffmpeg -loglevel error -hide_banner \
#  ffmpeg \
#    -reconnect 1 -reconnect_at_eof 1 -reconnect_streamed 1 -reconnect_delay_max 5 \
#  ffmpeg -loglevel info -hide_banner \
  ffmpeg \
    -thread_queue_size 4096 \
    -i pipe:0 \
    -map 0:a \
    -c:a aac -b:a 128k -ar 44100 \
    -f flv \
      "rtmp://localhost:1935/$MTX_PATH?user=${RTMP_APPLICATION_USERNAME}&pass=${RTMP_APPLICATION_PASSWORD}"
}

set -x
get_stream_source | set_stream_source
