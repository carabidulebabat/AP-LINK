#!/bin/bash

### install.sh script, will install everthing for aplink work, its use hostapd for main base https://w1.fi/cgit 

set -e
SSID="VTX-FLY"
WIFI_INTERFACE="wlx0013ef500122" #need to be change with nic name
## downloads aircrack ng or wifi driver that you want ###

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
cd hostap/hostapd
sudo cp defconfig .config
sudo make
sudo make install

#enable driver
sudo sed -i 's/#CONFIG_DRIVER_NL80211=y/CONFIG_DRIVER_NL80211=y/' .config

sudo make
sudo make install

WIFI_INTERFACE=$(ip -o link show | awk -F': ' '/wl/ {print $2; exit}')
##START ON CHANNEL 36 5.8GHZ## ON AP channel are set auto on gs, with tx power of 20dbm so 100mw###
echo "Création du fichier de configuration hostapd"
sudo bash -c "cat > /etc/hostapd/hostapd.conf <<EOF
interface=$WIFI_INTERFACE
driver=nl80211
ssid=$SSID
hw_mode=a
channel=36
ieee80211n=0
wmm_enabled=0
auth_algs=1
ignore_broadcast_ssid=0
macaddr_acl=0
max_num_sta=5
ap_max_inactivity=120
EOF"

echo "SET IP FIX AT $WIFI_INTERFACE"
sudo ip addr add 192.168.0.1/24 dev $WIFI_INTERFACE
sudo ip link set $WIFI_INTERFACE up

echo "WIFI AP '$SSID' '$WIFI_INTERFACE' hostapd compile successfully, download of dnsmasq."

sudo apt install dnsmasq

sudo bash -c 'cat > /etc/dnsmasq/dnsmasq.conf <<EOF
domain-needed
bogus-priv
filterwin2k
server=1.1.1.1
listen-address=192.168.0.1
no-hosts
dhcp-range=192.168.0.50,192.168.0.150,12h
EOF'


echo 'stream is launching, hostapd is working, end of code'

sudo dnsmasq -C /etc/dnsmasq/dnsmasq.conf

sudo /etc/hostapd/hostapd.conf
