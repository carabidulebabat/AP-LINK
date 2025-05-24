# lr-lowlatency-ap
##OPENSOURCE VIDEO SYSTEM FOR UAV, RC CAR, ROBOTS, OVER WIFI NETWORK## 
##OPENSOURCE VIDEO SYSTEM FOR UAV, RC CAR, ROBOTS, OVER WIFI NETWORK##
AUTHOR:
DEPENCIES : IW, HOSTAPD, Realtek driver,
WORK WITH MAJESTICS, GSTREAMER, VLC
Made for longrange via udp stream,
AUTO MODE : CHANNEL AND TX POWER ARE SET AUTOMATICLY
MANUAL MODE : Channel need to set manualy

USE HOSTAPD, NEED TO ADD CORRECT WIFI DRIVER FOR YOU CHIPSET

Max bitrate will be 50mbps video stream, add 10mbps for telemetry and data, so 60mbps max bitrate bitrate are handle by your decoder.
OSD can be render on air or gs, by default is air for better compatibility, osd will use opencv to show Mbps on stream.
note air render consume more processing power, can be problematics with ip cam soc, like ssc338q or other sigmastar.
Can be use with raspberry pi, radxa zero or other device that can run Linux
Not related to openipc or wfb ng or ruby, just a wifi protocol.

for first install run install.sh if done correctly the ap mode will start, just need to set your encoder for udp stream


Not configured for the moment
basic command: 
low_latency_ap --help will show every command avaible
low_latency_ap --mode manual / auto will change hostapd.conf 
auto will need a channel range
low_latency_ap start <ip> <port> <5.8ghz or 2.4ghz> will start video stream
low_latency_ap stop
Usage exempel : 
low_latency_ap start 192.168.1.10 5000 5.8ghz --mode manual=chan 60 
will output start on <chan> <dbm> 
