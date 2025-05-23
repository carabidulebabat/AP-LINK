!/bin/bash


if [["$EUID" -ne 0]]; then
    echo "run as root"e
    exit 1
fi

if [["$#" -ne 4]]; then
    echo "need ssid, domain, ghz, chan"
    exit 1
fi

$SSID=$1
$DOMAIN=$2
$ghz=$3
chan=$4


echo "Installing packages..."
apt update && apt install -y hostapd iw wpa_supplicant dnsmasq

echo "Stopping services while we configure them..."
systemctl stop hostapd
systemctl stop dnsmasq

echo "Writing hostapd.conf..."
cat > /etc/hostapd/hostapd.conf <<EOF
interface=wlan0
driver=nl80211
ssid=$SSID
hw_mode=$ghz
channel=$chan
auth_algs=1
rsn_pairwise=CCMP
country_code=$DOMAIN
EOF

echo "hostapd is starting on $ghz, channel $chan, avaible on network with $SSID"

systemctl start hostpad
systemctl start dnsmasq

echo "start successfully will configure rtsp udp ip"
echo "..."
echo ".."
echo "."

echo "set iw setting, like txpower"

iw wlan0 set tx power 20

 