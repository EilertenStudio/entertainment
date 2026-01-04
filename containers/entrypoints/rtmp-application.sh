#!/bin/sh

credentials_check() {
  if [ -z "${RTMP_SERVER_CREDENTIALS_FILE}" ]; then
    echo "Credentials file RTMP_SERVER_CREDENTIALS_FILE not found. Please provide it by environments."
    exit 101
  fi

  if [ -z "${RTMP_APPLICATION_CREDENTIALS_FILE}" ]; then
    echo "Credentials file RTMP_APPLICATION_CREDENTIALS_FILE not found. Please provide it by environments."
    exit 102
  fi
}

credentials_load() {
  echo "Loading credentials from ${1}"
  set -a
  . "${1}"
  set +a
}

radio_sources_download() {
  sh /srv/scripts/rtmp-application-source-radio-download.sh "$@"
}

#get_authorization_youtube() {
#  yt-dlp --username oauth2 --cache-dir /srv/scripts/.cache --playlist-items 0 https://www.youtube.com/watch?v=IxPANmjPaek
#}

credentials_load "${RTMP_SERVER_CREDENTIALS_FILE}"
credentials_load "${RTMP_APPLICATION_CREDENTIALS_FILE}"

#set -x

#export MTX_AUTHINTERNALUSERS_0_USER="${RTMP_APPLICATION_USERNAME}"
#export MTX_AUTHINTERNALUSERS_0_PASS="${RTMP_APPLICATION_PASSWORD}"

#get_authorization_youtube

if [ ! $# -eq 0 ]; then
  exec "$@"
else
  exec /mediamtx
fi