#!/bin/bash

DEVICE=/dev/video0
EDID_FILE=/opt/display/1080p50edid
MPLAYER_PID=""
HDMI_CONNECTED=false

start_mplayer() {
    echo "Starting mplayer..."
    mplayer tv:// \
        -tv driver=v4l2:device=$DEVICE:width=1920:height=1080:noaudio:outfmt=uyvy: \
        -fs -vo sdl -zoom -screenw 800 -screenh 480 &
    MPLAYER_PID=$!
}

stop_mplayer() {
    if [ -n "$MPLAYER_PID" ] && kill -0 "$MPLAYER_PID" 2>/dev/null; then
        echo "Stopping mplayer (PID $MPLAYER_PID)..."
        kill "$MPLAYER_PID"
        wait "$MPLAYER_PID" 2>/dev/null
    fi
    MPLAYER_PID=""
}

setup_video() {
    echo "Configuring video device..."
    v4l2-ctl --query-dv-timings
    sleep 1
    v4l2-ctl --set-dv-bt-timings query
    sleep 1
    v4l2-ctl --device=$DEVICE --set-fmt-video=width=1920,height=1080,pixelformat=UYVY
    sleep 1
}

is_hdmi_connected() {
    v4l2-ctl --query-dv-timings >/dev/null 2>&1
}

# ---- INITIAL SETUP ----
echo "Injecting EDID once..."
v4l2-ctl --set-edid=file=$EDID_FILE --fix-edid-checksums
sleep 2

echo "Monitoring HDMI connection and mplayer..."
while true; do
    if is_hdmi_connected; then
        if ! $HDMI_CONNECTED; then
            echo "HDMI connected!"
            HDMI_CONNECTED=true
            setup_video
            start_mplayer
        fi

        # If mplayer is not running, restart it
        if [ -z "$MPLAYER_PID" ] || ! kill -0 "$MPLAYER_PID" 2>/dev/null; then
            echo "mplayer crashed or exited. Restarting..."
            start_mplayer
        fi
    else
        if $HDMI_CONNECTED; then
            echo "HDMI disconnected!"
            HDMI_CONNECTED=false
            stop_mplayer
        fi
    fi

    sleep 1
done
