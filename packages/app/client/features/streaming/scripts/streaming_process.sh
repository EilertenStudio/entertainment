#!/bin/sh

#SCREEN_RESOLUTION="320x180"
#SCREEN_RESOLUTION="640x360"
SCREEN_RESOLUTION="1280x720"
#SCREEN_RESOLUTION="1920x1080"

#SCREEN_FPS="15"
SCREEN_FPS="30"
#SCREEN_FPS="60"

rtmp_output_url_get() {
  echo "$RTMP_SERVER_URL?user=${RTMP_SERVER_USERNAME}&pass=${RTMP_SERVER_PASSWORD}"
}

rtmp_process_start() {
  echo "[FFmpeg] Starting background process..."
  nohup ffmpeg -loglevel error -hide_banner \
    -fflags nobuffer \
    -f x11grab \
    -video_size "${SCREEN_RESOLUTION}" \
    -framerate ${SCREEN_FPS} \
    -draw_mouse 0 \
    -i :99.0 \
    -f pulse \
    -i "VirtualSink.monitor" \
    -c:v libx264 \
    -preset ultrafast \
    -b:v 3000k \
    -minrate 3000k \
    -maxrate 3000k \
    -bufsize 3000k \
    -x264opts "nal-hrd=cbr:force-cfr=1:filler=1:bitrate=3000" \
    -g 60 \
    -pix_fmt yuv420p \
    -c:a aac \
    -b:a 128k \
    -ar 44100 \
    -f flv "$(rtmp_output_url_get)" > /dev/null 2>&1 &

  echo $! > /tmp/ffmpeg_stream.pid
  echo "Started PID $(cat /tmp/ffmpeg_stream.pid)"
}

rtmp_process_stop() {
  if [ -f /tmp/ffmpeg_stream.pid ]; then
    PID=$(cat /tmp/ffmpeg_stream.pid)
    kill $PID
    rm /tmp/ffmpeg_stream.pid
    echo "Stopped PID $PID"
  else
    pkill -f "ffmpeg"
  fi
}

case "$1" in
  start)
    rtmp_process_start
    ;;
  stop)
    rtmp_process_stop
    ;;
esac
