#!/bin/bash

set -e

# Variables personnalisables
SSID="VTX-FLY"
PASSPHRASE="12345678"
WIFI_INTERFACE="wlx0013ef500122" #need to be change with nic name
INTERNET_INTERFACE="eth0"
## downloads aircrack ng or wifi driver that you want ###

echo "Installation des dépendances"
sudo apt update
sudo apt install -y build-essential libssl-dev libnl-3-dev libnl-genl-3-dev pkg-config git dnsmasq iptables dkms

git clone git clone -b v5.6.4.2 https://github.com/aircrack-ng/rtl8812au.git
cd rtl8812au
sudo make dkms_install

sudo apt update
sudo apt install -y build-essential libssl-dev libnl-3-dev libnl-genl-3-dev pkg-config git dnsmasq iptables dkms

echo "Téléchargement et compilation de hostapd"
cd /usr/local/src
sudo git clone https://w1.fi/hostap.git || true
cd hostap/hostapd
sudo cp defconfig .config

# Activer nl80211
sudo sed -i 's/#CONFIG_DRIVER_NL80211=y/CONFIG_DRIVER_NL80211=y/' .config

# Compilation
sudo make
sudo make install

ip addr show 

echo "Création du fichier de configuration hostapd"
sudo bash -c "cat > /usr/local/etc/hostapd.conf <<EOF
interface=$WIFI_INTERFACE
driver=nl80211
ssid=$SSID
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=1
wpa_passphrase=$PASSPHRASE
wpa_key_mgmt=WPA-PSK
rsn_pairwise=CCMP
EOF"

echo "[4/7] Configuration de dnsmasq (DHCP)"
sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.bak || true
sudo bash -c "cat > /etc/dnsmasq.conf <<EOF
interface=$WIFI_INTERFACE
dhcp-range=192.168.50.10,192.168.50.100,255.255.255.0,24h
EOF"

echo "[5/7] Attribution IP statique à $WIFI_INTERFACE"
sudo ip addr add 192.168.50.1/24 dev $WIFI_INTERFACE
sudo ip link set $WIFI_INTERFACE up

echo "[6/7] Activation du routage NAT"
sudo bash -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
sudo iptables -t nat -A POSTROUTING -o $INTERNET_INTERFACE -j MASQUERADE
sudo iptables -A FORWARD -i $INTERNET_INTERFACE -o $WIFI_INTERFACE -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i $WIFI_INTERFACE -o $INTERNET_INTERFACE -j ACCEPT

echo "[7/7] Démarrage des services"
sudo dnsmasq
sudo /usr/local/bin/hostapd /usr/local/etc/hostapd.conf &

echo "✅ Point d'accès Wi-Fi '$SSID' actif via hostapd compilé à partir des sources."

