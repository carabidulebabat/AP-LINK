#!/bin/bash

### install.sh script, will install everthing for aplink work, its use hostapd for main base https://w1.fi/cgit 

set -e
SSID="VTX-FLY"
WIFI_INTERFACE="wlan0/1" need to be change
## downloads aircrack ng or wifi driver that you want ###
######chmod to files#####

sudo chmod -R 777 /etc/

echo "install depedency......."
sudo apt update
sudo apt install -y build-essential libssl-dev libnl-3-dev libnl-genl-3-dev pkg-config git dnsmasq iptables dkms
sleep 2

echo "Install wifi driver for 8812au"

git clone -b v5.6.4.2 https://github.com/aircrack-ng/rtl8812au.git
cd rtl8812au
sudo make 
sudo make install

sleep 2


echo "download of hostapd"
sudo git clone https://w1.fi/hostap.git || true
cp defconfig /hostap/hostapd/.config
cd hostap/hostapd
echo"make...."
sudo make
#sudo make install

##START ON CHANNEL 36 5.8GHZ## ON AP channel are set auto on gs, with tx power of 20dbm so 100mw, ACS enable, will pick the best channel avaible###
echo "copy of hostapd.conf to /etc/hostapd/hostapd.conf....."
sudo cp hostapd.conf /etc/hostapd/hostapd.conf 
echo "WIFI AP '$SSID' '$WIFI_INTERFACE' hostapd compile successfully, download of dnsmasq."

sudo apt update
sudo apt install dnsmasq

sudo cp dnsmasq.conf /etc/dnsmasq.d/

echo "SET IP FIX AT $WIFI_INTERFACE"
sudo ip link set $WIFI_INTERFACE down
sudo ip addr add 192.168.0.1/24 dev $WIFI_INTERFACE
sudo ip link set $WIFI_INTERFACE up

sudo systemctl enable dnsmasq

echo 'stream is launching, hostapd is working, end of code' 

sudo hostapd /etc/hostapd/hostapd.conf
