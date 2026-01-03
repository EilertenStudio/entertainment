#!/bin/sh

SOURCE_MTX_URL="rtmp://localhost:1935/$MTX_PATH"
SOURCE_MUSIC_URL="rtmp://localhost:1935/source/music"

echo "[$MTX_PATH] Publish streaming to output"
exec \
  ffmpeg -loglevel error -hide_banner \
    -fflags nobuffer \
    -thread_queue_size 2048 \
    -i "$SOURCE_MTX_URL" \
    -thread_queue_size 2048 \
    -i "$SOURCE_MUSIC_URL" \
    -filter_complex \
      "[1:a]volume=0.45[bg]; \
       [0:a][bg]amix=inputs=2:duration=first:dropout_transition=0[aout]" \
    -map 0:v -map "[aout]" \
    -c:v copy \
    -c:a aac -b:a 192k -ar 44100 \
    -f flv "rtmp://localhost:1935/output?user=${RTMP_APPLICATION_USERNAME}&pass=${RTMP_APPLICATION_PASSWORD}"