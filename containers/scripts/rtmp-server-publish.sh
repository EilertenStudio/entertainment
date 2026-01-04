#!/bin/sh

. /srv/scripts/rtmp-common-utils.sh

publish_on_twitch() {
  ffmpeg -loglevel error -hide_banner \
    -re \
    -i rtmp://localhost:1935/output \
    -c copy \
    -f flv "rtmp://mil02.contribute.live-video.net/app/${TWITCH_STREAMING_KEY}"
}

if [ "${PUBLISH_ON_TWITCH}" -eq 1 ]; then
  log "Publish on TWITCH enabled"
  publish_on_twitch
else
  log "No publishing. Waiting for 5 minutes..."
  sleep 300000
fi
