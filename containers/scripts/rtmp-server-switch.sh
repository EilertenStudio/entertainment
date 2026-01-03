#!/bin/sh

STREAMING_PATH="$1"

if [ "$STREAMING_PATH" = "live" ]; then
    echo "[$STREAMING_PATH] Streaming on starting. Taking priority."
    pkill -f "ffmpeg -i rtmp://localhost:1935/application"
    sleep 0.5
fi

if [ "$STREAMING_PATH" = "application" ]; then
    if ps aux | grep -v grep | grep -q "ffmpeg -i rtmp://localhost:1935/live"; then
#        echo "[$STREAMING_PATH] Detect live streaming on progress. Abort operation."
        exit 0
    fi
fi

echo "[$STREAMING_PATH] Switching output streaming"
exec \
  ffmpeg -loglevel error -hide_banner \
    -i "rtmp://localhost:1935/$STREAMING_PATH" \
    -c copy \
    -f flv "rtmp://localhost:1935/output?user=${RTMP_SERVER_USERNAME}&pass=${RTMP_SERVER_PASSWORD}"