#!/bin/sh

STREAMING_PATH="$1"

publish_on_twitch() {
  ffmpeg -loglevel error -hide_banner \
    -re \
    -i rtmp://localhost:1935/output \
    -c copy \
    -f flv "rtmp://mil02.contribute.live-video.net/app/${TWITCH_STREAMING_KEY}"
}

if [ "${PUBLISH_ON_TWITCH}" -eq 1 ]; then
  echo "[$STREAMING_PATH] Publish on TWITCH enabled"
  publish_on_twitch
fi
