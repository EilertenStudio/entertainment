#!/bin/sh

echo "Recupero URL da Twitch per: $TWITCH_CHANNEL_NAME..."
STREAM_QUALITY_BEST="best"
STREAM_QUALITY_720p60fps="best[height<=720][fps<=30]/bestvideo[height<=720][fps<=30]+bestaudio/best"
STREAM_URL=$(
  yt-dlp \
    --quiet \
    --no-warnings \
    -f "$STREAM_QUALITY_BEST" \
    -g "https://www.twitch.tv/$TWITCH_CHANNEL_NAME"
)

if [ -z "$STREAM_URL" ]; then
    echo "Errore: Impossibile recuperare l'URL. Il canale è offline?"
    exit 1
fi

echo "URL recuperato. Avvio FFmpeg..."

exec ffmpeg \
  -reconnect 1 \
  -reconnect_at_eof 1 \
  -reconnect_streamed 1 \
  -reconnect_delay_max 5 \
  -thread_queue_size 4096 \
  -i "$STREAM_URL" \
  -c:v libx264 \
  -preset ultrafast \
  -tune zerolatency \
  -bf 0 \
  -c:a libopus \
  -b:a 128k \
  -ar 48000 \
  -vsync cfr \
  -f flv \
    "$RTMP_SERVER_URL"