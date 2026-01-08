#!/bin/sh

load_credentials() {
  echo "Loading credentials from ${1}"
    set -a
    . "${1}"
    set +a
}

rtmp_output_url_get() {
  echo "$RTMP_SERVER_URL?user=${RTMP_SERVER_USERNAME}&pass=${RTMP_SERVER_PASSWORD}"
}

load_credentials "${RTMP_SERVER_CREDENTIALS_FILE}"

pulseaudio_start() {
  echo ""
  echo "-----------------------------------------------"
  echo "[Pulseaudio] Clean up files"
  rm -rf /var/run/pulse /var/lib/pulse /root/.config/pulse
    rm -f /tmp/pulse-* # Pulisce anche i socket temporanei

    echo "[Pulseaudio] Running audio..."
    # Nota: Non esportare il PID qui perché con -D il PID di shell muore subito
    pulseaudio -D --exit-idle-time=-1 --system=false --disallow-exit --disable-shm

    timeout=10
    while ! pactl info >/dev/null 2>&1; do
        echo "[Pulseaudio] Waiting for server..."
        sleep 1
        ((timeout--))
        if [ $timeout -le 0 ]; then echo "[ERR] PulseAudio failed to start"; return 1; fi
    done

    echo "[Pulseaudio] Configuring modules..."

    # Carica il null-sink
    pactl load-module module-null-sink sink_name=VirtualSink sink_properties=device.description="Virtual_Output"

    # Disabilita il suspend (spostato qui per sicurezza dopo il caricamento del sink)
    pactl load-module module-suspend-on-idle timeout=0 || echo "[WARN] Suspend module already loaded or failed, ignoring."

    # Imposta default e volumi
    pactl set-default-sink VirtualSink
    pactl set-sink-mute VirtualSink false
    pactl set-sink-volume VirtualSink 100%

    echo "[Pulseaudio] OK"
}

xvfb_start() {
  echo ""
  echo "-----------------------------------------------"
  echo "[Xvfb] Clean up files"
  rm -f /tmp/.X99-lock

#  echo "-----------------------------------------------"
#  echo "[Xvfb] Running display on :99 (1920x1080x24)..."
#  echo "-----------------------------------------------"
#  Xvfb :99 -screen 0 1920x1080x24 -ac +extension GLX +render -noreset &

  echo "-----------------------------------------------"
  echo "[Xvfb] Running optimized display on :99 (320x180x16)..."
  Xvfb :99 -screen 0 320x180x16 -ac +extension GLX +render -noreset &

  export XVFB_PID=$!

#  fluxbox &
#
#  export FLUXBOX_PID=$!

#  x11vnc -display :99 -nopw -forever -quiet &
#
#  export X11VNC_PID=$!

  until xset -display :99 q > /dev/null 2>&1; do
      echo "[Xvfb] Waiting on :99..."
      sleep 1
  done
  echo "[Xvfb] OK"

  export DISPLAY=:99
  export LIBGL_ALWAYS_SOFTWARE=1
}

ffmpeg_start() {
  echo ""
  echo "-----------------------------------------------"
  echo "[FFmpeg] Running streaming server"
  echo "-----------------------------------------------"
  (
    ffmpeg -loglevel error -hide_banner \
      -fflags nobuffer \
      -f x11grab \
      -video_size 320x180 \
      -framerate 30 \
      -draw_mouse 0 \
      -i :99.0 \
      -f pulse \
      -i "VirtualSink.monitor" \
      -vf "scale=1920:1080:flags=neighbor" \
      -c:v libx264 \
      -preset ultrafast \
      -b:v 3000k \
      -minrate 3000k \
      -maxrate 3000k \
      -bufsize 3000k \
      -x264opts "nal-hrd=cbr:force-cfr=1:filler=1:bitrate=3000" \
      -g 60 \
      -pix_fmt yuv420p \
      -c:a aac \
      -b:a 128k \
      -ar 44100 \
      -f flv "$(rtmp_output_url_get)"
  ) &

  export FFMPEG_PID=$!

  echo "[FFmpeg] Waiting for initialization..."
  sleep 5
  echo "[FFmpeg] OK"
}

godot_start() {
  echo ""
  echo "-----------------------------------------------"
  echo "[Godot] Running application on :99..."
  echo "-----------------------------------------------"
  godot --path /srv \
        --single-threaded \
        --display-driver x11 \
   >&1 &

  export GODOT_PID=$!
  echo "[Godot] Started with PID $GODOT_PID"

}

echo "-----------------------------------------------"
echo "[Main] Configure signal handler"
echo "-----------------------------------------------"

trap 'echo "[Cleanup] Stopping background processes..."; kill 0' EXIT

echo "-----------------------------------------------"
echo "[Main] Start system processes"
echo "-----------------------------------------------"

pulseaudio_start
xvfb_start
#ffmpeg_start
godot_start

echo "-----------------------------------------------"
echo "[Main] All systems go. Bringing Godot to foreground..."
echo "-----------------------------------------------"

wait $GODOT_PID
