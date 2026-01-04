#!/bin/sh

. /srv/scripts/rtmp-common-init.sh

radio_file_create() {
  ls "${RTMP_APPLICATION_SOURCE_RADIO_MUSIC_DIR}/sources"/*.mp3 | sed "s/^/file '/;s/$/'/" > "${RTMP_APPLICATION_SOURCE_RADIO_MUSIC_DIR}/sources.txt"

  if [ -f "${RTMP_APPLICATION_SOURCE_RADIO_FILE}" ]; then
    rm -f "${RTMP_APPLICATION_SOURCE_RADIO_FILE}"
  fi

  ffmpeg -f concat -safe 0 -i "${RTMP_APPLICATION_SOURCE_RADIO_MUSIC_DIR}/sources.txt" -c copy "${RTMP_APPLICATION_SOURCE_RADIO_FILE}"
}

stream_source_get() {
  cat "${RTMP_APPLICATION_SOURCE_RADIO_FILE}"
}

stream_source_publish() {
  ffmpeg \
  -re \
  -stream_loop -1 \
  -i pipe:0 \
  -c:a aac -b:a 192k -ar 44100 \
  -f flv "rtmp://localhost:1935/$MTX_PATH?user=${RTMP_APPLICATION_USERNAME}&pass=${RTMP_APPLICATION_PASSWORD}"
}

#set -x
radio_file_create

stream_source_get | stream_source_publish