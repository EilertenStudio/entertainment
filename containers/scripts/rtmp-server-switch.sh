#!/bin/sh

. /srv/scripts/rtmp-common-utils.sh

if [ "$MTX_PATH" = "live" ]; then
    log "Streaming on starting. Taking priority."
    pkill -f "ffmpeg -i rtmp://localhost:1935/application"
    sleep 0.5
fi

if [ "$MTX_PATH" = "application" ]; then
    if ps aux | grep -v grep | grep -q "ffmpeg -i rtmp://localhost:1935/live"; then
#        echo "[$STREAMING_PATH] Detect live streaming on progress. Abort operation."
        exit 0
    fi
fi

log "Switching output streaming"
exec \
  ffmpeg -loglevel error -hide_banner \
    -i "rtmp://localhost:1935/$MTX_PATH" \
    -c copy \
    -f flv "rtmp://localhost:1935/output?user=${RTMP_SERVER_USERNAME}&pass=${RTMP_SERVER_PASSWORD}"