#!/bin/bash

### install.sh script, will install everthing for aplink work, its use hostapd for main base https://w1.fi/cgit 

set -e

# Variables personnalisables
SSID="VTX-FLY"
WIFI_INTERFACE="wlx0013ef500122" #need to be change with nic name
## downloads aircrack ng or wifi driver that you want ###

echo "Installation des dépendances"
sudo apt update
sudo apt install -y build-essential libssl-dev libnl-3-dev libnl-genl-3-dev pkg-config git dnsmasq iptables dkms

git clone -b v5.6.4.2 https://github.com/aircrack-ng/rtl8812au.git
cd rtl8812au
sudo make 
sudo make install


echo "Téléchargement et compilation de hostapd"
cd /usr/local/src
sudo git clone https://w1.fi/hostap.git || true
cd hostap/hostapd
sudo cp defconfig .config
sudo make
sudo make install

# Activer nl80211
sudo sed -i 's/#CONFIG_DRIVER_NL80211=y/CONFIG_DRIVER_NL80211=y/' .config

# Compilation
sudo make
sudo make install

WIFI_INTERFACE=$(ip -o link show | awk -F': ' '/wl/ {print $2; exit}')
##START ON CHANNEL 36 5.8GHZ## ON AP channel are set auto on gs, with tx power of 20dbm so 100mw###
echo "Création du fichier de configuration hostapd"
sudo bash -c "cat > /usr/local/etc/hostapd.conf <<EOF
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

echo "[5/7] Attribution IP statique à $WIFI_INTERFACE"
sudo ip addr add 192.168.4.1/24 dev $WIFI_INTERFACE
sudo ip link set $WIFI_INTERFACE up

echo "[6/7] Activation du routage NAT"
sudo bash -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
sudo iptables -t nat -A POSTROUTING -o $INTERNET_INTERFACE -j MASQUERADE
sudo iptables -A FORWARD -i $INTERNET_INTERFACE -o $WIFI_INTERFACE -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i $WIFI_INTERFACE -o $INTERNET_INTERFACE -j ACCEPT

echo "[7/7] Démarrage des services"
sudo /usr/local/bin/hostapd /usr/local/etc/hostapd.conf &

echo "Point d'accès Wi-Fi '$SSID' '$WIFI_INTERFACE' actif via hostapd compilé à partir des sources."

echo 'lancement du stream'

sudo apt install ffmpeg

echo 'ffmpeg installer, attente de confirmation manuel, fin du programme install.sh'

