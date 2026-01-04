#!/bin/sh

radio_sources_download() {
  if [ ! -d "${RTMP_APPLICATION_SOURCE_RADIO_MUSIC_DIR}" ]; then
    mkdir -p "${RTMP_APPLICATION_SOURCE_RADIO_MUSIC_DIR}"
  fi

  for url in $*; do
    yt-dlp -x --audio-format mp3 -o "$RTMP_APPLICATION_SOURCE_RADIO_MUSIC_DIR/sources/%(title)s.%(ext)s" "$url"
  done
}


radio_sources_download $@