#!/bin/sh

. /srv/scripts/rtmp-common-init.sh

SOURCE_URL="$1"
SOURCE_COOKIES="$RTMP_APPLICATION_YOUTUBE_COOKIES_FILE"

get_stream_source() {
  return 0
}

set_stream_source() {
  return 0
}

#set -x
#get_stream_source | set_stream_source

log "Not implemented yet!"