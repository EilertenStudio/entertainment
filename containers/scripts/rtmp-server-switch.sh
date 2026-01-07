#!/bin/sh

. /srv/scripts/rtmp-common-utils.sh

log "Init source switching"

#log "-----------------------------------------------------------"
#ps aux
#log "-----------------------------------------------------------"

if [ "$MTX_PATH" = "live" ]; then
    log "Streaming on starting. Taking priority."
    pkill -f "rtmp://localhost:1935/application"
    sleep 1
fi

if [ "$MTX_PATH" = "application" ]; then
    if [ -n "$(pgrep -f "rtmp://localhost:1935/live")" ]; then
        log "Detect live streaming in progress. Abort operation."
        sleep 15
        exit 0
    fi
fi

#log "-----------------------------------------------------------"
#ps aux
#log "-----------------------------------------------------------"

log "Switching output streaming"
exec \
  ffmpeg -loglevel error -hide_banner \
    -i "rtmp://localhost:1935/$MTX_PATH" \
    -c copy \
    -f flv "rtmp://localhost:1935/output?user=${RTMP_SERVER_USERNAME}&pass=${RTMP_SERVER_PASSWORD}"