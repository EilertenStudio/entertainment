FROM barichello/godot-ci:4.5.1

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    xvfb \
    x11-xserver-utils \
    libxcursor1 \
    libxinerama1 \
    libxrandr2 \
    libxi6 \
    libgl1-mesa-dri \
    libglx-mesa0 \
    libvulkan1 \
    ffmpeg \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

 RUN apt-get update && apt-get install -y --no-install-recommends \
     xvfb \
     x11-xserver-utils \
     pulseaudio \
     pavucontrol \
     && apt-get clean && rm -rf /var/lib/apt/lists/*