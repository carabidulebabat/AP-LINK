#!/bin/bash

### install.sh script, will install everthing for aplink work, its use hostapd for main base https://w1.fi/cgit 

set -e

if [-z "$1"]; then
  echo "error need install.sh (wifi_interface)"
  exit(0)

interface=$1

sudo mkdir /etc/aplink

cp -r /vtx/ /etc/aplink

echo "install depedency......."
sudo apt update
sudo apt install -y build-essential libssl-dev libnl-3-dev libnl-genl-3-dev pkg-config git dnsmasq iptables dkms
sleep 2

echo "Install wifi driver for 8812au"

git clone -b v5.6.4.2 https://github.com/aircrack-ng/rtl8812au.git
cd rtl8812au
sudo make 
sudo make install
cd
sleep 2


echo "download of hostapd"
sudo git clone https://w1.fi/hostap.git || true
cp defconfig /hostap/hostapd/.config
cd hostap/hostapd
echo"make...."
sudo make
#sudo make install

##START ON tx power of 20dbm so 100mw, ACS enable, will pick the best channel avaible###
echo "copy of hostapd.conf to /etc/hostapd/hostapd.conf....."
cd /etc/aplink
sed -i "s/^interface=\$WIFI_INTERFACE/interface=$interface/" /etc/aplink/hostapd.conf
sudo cp hostapd.conf /etc/hostapd/hostapd.conf 
echo "WIFI AP '$SSID' '$interface' hostapd compile successfully, download of dnsmasq."

sudo apt update
sudo apt install dnsmasq

sudo cp dnsmasq.conf /etc/dnsmasq.d/

echo "SET IP FIX AT $interface"
sudo ip link set $interface down
sudo ip addr add 192.168.0.1/24 dev $interface
sudo ip link set $interface up

sudo systemctl enable dnsmasq

sudo cp aplink.service /etc/systemd/system/

sudo systemctl enable aplink.service

systemctl disable NetworkManager

echo"end of the program"

