#!/bin/sh

sh /srv/scripts/rtmp-common-init.sh

YT_URL="https://www.youtube.com/watch?v=IxPANmjPaek"

echo "Accessing YouTube Medieval Lofi..."

#exec \
#  yt-dlp --ignore-errors --quiet --no-progress --no-warnings \
#    --js-runtimes node \
#    -o - \
#    -f "91/92/93/best" \
#    "$YT_URL" \
#  | \
#  ffmpeg -loglevel error -hide_banner \
#      -thread_queue_size 2048 \
#      -i pipe:0 \
#      -vn \
#      -c:a aac -b:a 128k -ar 44100 \
#      -af "aresample=async=1" \
#      -f flv "rtmp://localhost:1935/source/music"

yt-dlp --js-runtimes node \
    --quiet --no-progress --no-warnings \
    -o - -f "91/92/93/best" "$YT_URL" | \
ffmpeg -loglevel error -hide_banner \
    -analyzeduration 10M -probesize 10M \
    -thread_queue_size 4096 \
    -i pipe:0 \
    -map 0:a \
    -vn \
    -c:a aac -b:a 128k -ar 44100 \
    -f flv "rtmp://localhost:1935/$MTX_PATH?user=${RTMP_APPLICATION_USERNAME}&pass=${RTMP_APPLICATION_PASSWORD}"