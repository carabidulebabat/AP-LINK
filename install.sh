#!/bin/bash

### install.sh script, will install everthing for aplink work, its use hostapd for main base https://w1.fi/cgit 

set -e
SSID="VTX-FLY"
WIFI_INTERFACE="wlx0013ef500122" #need to be change with nic name
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
cd /usr/local/src
sudo git clone https://w1.fi/hostap.git || true
cp defconfig /usr/local/src/hostap/hostapd
cd hostap/hostapd
sudo cp defconfig .config

#enable driver
sudo cpd

sudo make
sudo make install

WIFI_INTERFACE=$(ip -o link show | awk -F': ' '/wl/ {print $2; exit}')

##START ON CHANNEL 36 5.8GHZ## ON AP channel are set auto on gs, with tx power of 20dbm so 100mw, ACS enable, will pick the best channel avaible###
echo "Création du fichier de configuration hostapd"
sudo bash -c "cat > /etc/hostapd/hostapd.conf <<EOF
interface=$WIFI_INTERFACE
hw_mode=a
channel=0
country_code=US
# 802.11ac support
ieee80211ac=1
wmm_enabled=1
ssid=VTX
auth_algs=1
EOF"

echo "WIFI AP '$SSID' '$WIFI_INTERFACE' hostapd compile successfully, download of dnsmasq."

sudo apt update
sudo apt install dnsmasq

sudo cp dnsmasq.conf /etc/dnsmasq.d/

echo "SET IP FIX AT $WIFI_INTERFACE"
sudo ip link set $WIFI_INTERFACE down
sudo ip addr add 192.168.0.1/24 dev $WIFI_INTERFACE
sudo ip link set $WIFI_INTERFACE up

sudo systemctl restart dnsmasq

echo 'stream is launching, hostapd is working, end of code' 

sudo hostapd /etc/hostapd/hostapd.conf
