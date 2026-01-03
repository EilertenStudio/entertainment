#!/bin/sh

load_credentials() {
  echo "Loading credentials from ${1}"
  set -a
  . "${1}"
  set +a
}

load_credentials "${RTMP_SERVER_CREDENTIALS_FILE}"
load_credentials "${RTMP_APPLICATION_CREDENTIALS_FILE}"

#export MTX_AUTHINTERNALUSERS_0_USER="${RTMP_APPLICATION_USERNAME}"
#export MTX_AUTHINTERNALUSERS_0_PASS="${RTMP_APPLICATION_PASSWORD}"

exec /mediamtx