#!/bin/sh

load_credentials() {
  echo "Loading credentials from ${CREDENTIALS_FILE}"
  set -a
  . "${CREDENTIALS_FILE}"
  set +a
}

load_credentials

#export MTX_AUTHINTERNALUSERS_0_USER="${RTMP_SERVER_USERNAME}"
#export MTX_AUTHINTERNALUSERS_0_PASS="${RTMP_SERVER_PASSWORD}"

exec /mediamtx