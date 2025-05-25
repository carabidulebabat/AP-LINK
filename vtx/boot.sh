!/bin/bash

#INIT HOSTAPD, SET STATIC IP#

sudo systemctl disable wpa_supplicant
sudo systemctl disable NetworkManager

sudo ip link set wlx0013ef500122 down
sudo iw dev wlx0013ef500122 set type __ap
sudo ip link set wlx0013ef500122 up

sudo hostapd /etc/hostapd/hostapd.conf

##STREAM WITH FFMEG FOR EXEMPLE at 15mbps##

ffmpeg -f v4l2 -input_format mjpeg -video_size 1280x720 -i /dev/video0 \
  -c:v libx264 -b:v 15M -preset ultrafast -tune zerolatency \
  -f mpegts udp://192.168.4.2:5000

echo "SET IP FIX AT WLAN1"
sudo ip link set wlx0013ef500122 down
sudo ip addr add 192.168.0.1/24 dev wlx0013ef500122
sudo ip link set wlx0013ef500122 up

echo "WIFI AP 'VTX' 'wlan1' hostapd compile successfully, download of dnsmasq."

sudo apt install dnsmasq

sudo bash -c "cat /etc/dnsmasq.conf << EOF
domain-needed
bogus-priv
filterwin2k
server=1.1.1.1
listen-address=192.168.0.1
no-hosts
dhcp-range=192.168.0.50,192.168.0.150,infinite
EOF"

echo 'stream is launching, hostapd is working, end of code'

sudo systemctl enable dnsmas

sudo hostapd /etc/hostapd/hostapd.conf