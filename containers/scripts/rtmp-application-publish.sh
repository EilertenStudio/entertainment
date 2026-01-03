#!/bin/sh

echo "[$MTX_PATH] Publish streaming to rtmp-server"
exec \
  ffmpeg -loglevel error -hide_banner \
    -i "rtmp://localhost:1935/$MTX_PATH" \
    -c copy \
    -f flv "rtmp://rtmp-server:1935/application?user=${RTMP_SERVER_USERNAME}&pass=${RTMP_SERVER_PASSWORD}"