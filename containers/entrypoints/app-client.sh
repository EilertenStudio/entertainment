#!/bin/sh

load_credentials() {
  echo "Loading credentials from ${1}"
    set -a
    . "${1}"
    set +a
}

load_credentials "${RTMP_APPLICATION_CREDENTIALS_FILE}"

export

echo ""
echo "-----------------------------------------------"
echo "[Pulseaudio] Clean up files"
rm -rf /var/run/pulse /var/lib/pulse /root/.config/pulse

echo "[Pulseaudio] Running audio..."
pulseaudio -D --exit-idle-time=-1 --system=false --disallow-exit
pactl load-module module-null-sink sink_name=VirtualSink sink_properties=device.description="Virtual_Output"
pactl set-default-sink VirtualSink

echo ""
echo "-----------------------------------------------"
echo "[Xvfb] Clean up files"
rm -f /tmp/.X99-lock

echo "[Xvfb] Running display on :99..."
Xvfb :99 -screen 0 1280x720x24 -ac +extension GLX +render -noreset &

until xset -display :99 q > /dev/null 2>&1; do
    echo "[Xvfb] Waiting on :99..."
    sleep 1
done
echo "[Xvfb] OK"

export DISPLAY=:99
export LIBGL_ALWAYS_SOFTWARE=1

echo ""
echo "-----------------------------------------------"
echo "[FFmpeg] Running streaming server"
(
  ffmpeg -loglevel error -hide_banner \
    -f x11grab \
    -thread_queue_size 1024 \
    -draw_mouse 0 \
    -video_size 1280x720 \
    -framerate 30 \
    -i :99.0 \
    -f pulse \
    -thread_queue_size 1024 \
    -i VirtualSink.monitor \
    -c:v libx264 \
    -preset ultrafast \
    -tune zerolatency \
    -threads 1 \
    -bf 0 \
    -pix_fmt yuv420p \
    -c:a aac \
    -b:a 128k \
    -ar 44100 \
    -af "aresample=async=1:min_hard_comp=0.100000:first_pts=0" \
    -f flv "$RTMP_APPLICATION_URL?user=${RTMP_APPLICATION_USERNAME}&pass=${RTMP_APPLICATION_PASSWORD}" \
) &



FFMPEG_PID=$!

echo "[FFmpeg] Waiting for initialization..."
sleep 5
echo "[FFmpeg] OK"

echo ""
echo "-----------------------------------------------"
#echo "[APP] Running application in background on :99..."
echo "[APP] Running application on :99..."
echo "-----------------------------------------------"
(
  godot --path /runner --display-driver x11 --rendering-driver opengl3 --audio-driver PulseAudio \
    >&1; kill -TERM $$
)

#GODOT_PID=$!

#echo "[APP] Waiting for initialization..."
#sleep 5
#echo "[APP] OK"