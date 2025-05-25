!/bin/bash

#INIT HOSTAPD, SET STATIC IP#

sudo ip link set wlx0013ef500122 down
sudo iw dev wlx0013ef500122 set type __ap
sudo ip link set wlx0013ef500122 up

echo "SET IP FIX AT wlx0013ef500122"
sudo ip link set wlx0013ef500122 down
sudo ip addr add 192.168.0.1/24 dev wlx0013ef500122
sudo ip link set wlx0013ef500122 up

sudo hostapd /etc/hostapd/hostapd.conf
ffmpeg -re -f v4l2 -i /dev/video0 -r 10 -f mpegts -fflags nobuffer -flags low_delay udp://192.168.0.131:8554?pkt_size=1316
