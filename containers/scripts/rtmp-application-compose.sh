#!/bin/sh

. /srv/scripts/rtmp-common-utils.sh

#SOURCE_MTX_URL="rtmp://localhost:1935/$MTX_PATH"
#SOURCE_RADIO_URL="rtmp://localhost:1935/source/radio"
#
#log "Publish streaming to output"
#exec \
#  ffmpeg -loglevel error -hide_banner \
#    -fflags nobuffer \
#    -thread_queue_size 2048 \
#    -i "$SOURCE_MTX_URL" \
#    -thread_queue_size 2048 \
#    -i "$SOURCE_RADIO_URL" \
#    -filter_complex \
#      "[1:a]volume=0.45[bg]; \
#       [0:a][bg]amix=inputs=2:duration=first:dropout_transition=0[aout]" \
#    -map 0:v -map "[aout]" \
#    -c:v copy \
#    -c:a aac -b:a 192k -ar 44100 \
#    -f flv "rtmp://localhost:1935/output?user=${RTMP_APPLICATION_USERNAME}&pass=${RTMP_APPLICATION_PASSWORD}"

MAIN_URL="rtmp://localhost:1935/source/main"
MUSIC_URL="rtmp://localhost:1935/source/radio"
OUTPUT_URL="rtmp://localhost:1935/output"

# Calcolo Bitrate:
# Video: 2800k | Audio: 192k | Totale: ~3000k
V_BITRATE="2800k"
A_BITRATE="192k"
BUF_SIZE="6000k" # Doppio del bitrate per gestire i picchi (VBV Buffer)

log "Publish streaming to output"

while true; do
    ffmpeg -hide_banner -loglevel error \
      -fflags nobuffer \
      -i "$MAIN_URL" \
      -i "$MUSIC_URL" \
      -filter_complex \
        "[1:a]volume=0.45[bg]; \
         [0:a][bg]amix=inputs=2:duration=first:dropout_transition=0[aout]" \
      -map 0:v -map "[aout]" \
      -c:v libx264 -preset veryfast \
      -b:v $V_BITRATE -maxrate $V_BITRATE -bufsize $BUF_SIZE \
      -pix_fmt yuv420p -g 60 \
      -c:a aac -b:a $A_BITRATE -ar 44100 \
      -f flv "rtmp://localhost:1935/output?user=${RTMP_APPLICATION_USERNAME}&pass=${RTMP_APPLICATION_PASSWORD}"

    log "Finish ffmpeg process. Restarting in 2s ..."
    sleep 2
done