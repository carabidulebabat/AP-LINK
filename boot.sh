!/bin/bash

#INIT HOSTAPD, SET STATIC IP#
interface="interface"

sudo ip link set $interface down
sudo iw dev $interface set type __ap
sudo ip link set $interface up

sudo ip link set $interface down
sudo ip addr add 192.168.0.1/24 dev $interface
sudo ip link set $interface up

sudo hostapd /etc/hostapd/hostapd.conf
